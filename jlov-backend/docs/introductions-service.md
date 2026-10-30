# Introductions Service Documentation

## Service Overview

The Introductions Service manages the core matchmaking functionality of the JLOV dating platform. It handles user introductions, match suggestions, profile matching algorithms, introduction lifecycle management, and administrative operations. The service is responsible for creating meaningful connections between users based on compatibility algorithms and user preferences.

## Service Details

- **Runtime**: Node.js 22.x
- **Authentication**: AWS Cognito User Pools
- **Matchmaking Algorithms**: Compatibility scoring and filtering
- **Database**: Introductions and matches database

## Lambda Functions

### Match Discovery Functions

#### findMatches
**Purpose**: Finds potential matches for a user based on compatibility criteria
- **Handler**: `src/functions/findMatches.findMatchesHandler`
- **Path**: `/matches`
- **Method**: GET
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.limit` (optional) - Number of matches to retrieve
  - `queryStringParameters.offset` (optional) - Pagination offset
  - `queryStringParameters.filters` (optional) - Additional filtering criteria
- **Returns**:
  - `200` - Matches found successfully
  - `401` - Unauthorized
  - `500` - Server error

#### makeRawSuggestions
**Purpose**: Generates raw match suggestions for users
- **Handler**: `src/functions/makeRawSuggestions.makeRawSuggestionsHandler`
- **Path**: `/suggestions`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.userId` - ID of the user to generate suggestions for
  - `body.preferences` (optional) - User preferences for matching
  - `body.limit` (optional) - Number of suggestions to generate
- **Returns**:
  - `201` - Suggestions generated successfully
  - `400` - Invalid user data
  - `401` - Unauthorized
  - `500` - Server error

When the matching service (Meeplus AI) responds with an error whose message includes `Profile attachment is empty` (missing `attachmentResult` in profile external info), this handler calls profile-service `GET /profiles/predictor/{profile_id}` once. That endpoint runs `predictor_attachmentCalc` when needed, then the matching suggestions request is retried so scoring can proceed. Both outbound calls use `@jlov/infra-lib` helpers (`getMatchingSuggestions`, `getProfilePredictor`) built on the same `makeRequest`-style HTTP client as other facades.

When `pendingIntroductionsMode = "noTolerance"`, suggestions are routed to `PENDING` only if:
- `AnyDeclined3516` is true for either side, or
- the matching-service response contains `tolerance_used` entries and at least one of those attributes has `profile_attributes.settings.pendingOnTolerance = true` for the brand.

`tolerance_used` is an array of attribute names (for example `["agePref", "heightPref"]`) indicating exactly which attributes required tolerance during scoring.

When an introduction is created in `PENDING` under `noTolerance`, `introductions.status_reason` stores admin-facing metadata: `toleranceUsedAttributes` (copy of `tolerance_used`), `pendingDueToPastDeclines` when `AnyDeclined3516` is set for either side, and `initiatorPastDeclineAttributeKeys` / `responderPastDeclineAttributeKeys` (profile attribute keys ending in `Declined3516` that are set, for example per-past-attribute decline markers).

After a new introduction is persisted and reaches a “raw suggestion” state (`RAW`, `PENDING`, or `AVAILABILITY_CHECK` after `publishNewIntro`), the service **asynchronously** invokes the private `computeMatchAdvisor` endpoint via the user-events queue (`TechnicalEvent.LAMBDA_CALL`), so the HTTP path to suggestions returns without waiting for OpenAI.

#### computeMatchAdvisor
**Purpose**: Builds the match-advisor context for the pair, calls OpenAI once (one retry), applies code checks to the reply, and saves the result on `introductions.llm_match_advisor` (JSONB). The same context, LLM call and checks also populate `public.ai_pair_assessment` for the matcher's AI blend (#84389/#84390) via the **candidate list ranker** (`executeCandidateRanking`) when `AppFeatures.candidateListRanking` is on for the brand: jlov runs ranking **before** cron/async suggestions (using `rank_pool` from the matching service) instead of the removed 6-hour `aiPairAssessmentPrecheck` cron. Sync HTTP `makeRawSuggestions` still creates unranked suggestions immediately and ranks in the background. The **system prompt** must be configured on the `match-advisor` agent (`general_codes.extra.prompt`); there is no in-repo default (the current draft is `meta-repo/scripts/match_advisor_prompt_update/match_advisor_prompt_v3.md`).
- **Context** (`infra-lib/src/facades/matchAdvisorContextFacade.ts`), per person (A = initiator, B = responder):
  - `initiator` / `responder`: `{ bio, preferences, aiAnalysisPref, freeText[] }`. Labels and values are translated; `freeText` holds answers to Text questions as `{ label, group: "bio" | "pref", text }` (jlov PR #2475 — before it, bio and pref attributes were one map keyed by label, so a shared label overwrote one of them).
  - `declinesInitiator` / `declinesResponder`: up to 5 recent decline questionnaires (`batch.extra.declineBatch`) in the member's own words, each with the declined match's bio and free text (`memberDeclinesFacade.ts`, #2475).
  - `learningSummaryForA/B` (#84397), `predictorAnswers*`, `dealBreakerMeta*`, `compatibilityTopics` (`aiCompatibilityTopic` rows, #84382).
  - Algorithm scores are not sent.
  - Contact data is never sent: answers whose question `response_settings.inputType` is email/phone are dropped, and e-mails / phone numbers inside values are masked (`infra-lib/src/llmContactRedaction.ts`). The decline and match-end investigators get the same redaction.
  - `computeMatchAdvisorInputHash` hashes the context (without the introduction id for precheck) and is the cache key in `ai_pair_assessment`.
- **Handler**: `src/functions/private/computeMatchAdvisor.computeMatchAdvisorHandler`
- **Path**: `/private/introductions/{introductionId}/match-advisor`
- **Method**: POST
- **Timeout**: 120 seconds
- **Private**: true (API key)
- **Agent settings (DB)**: resolves `general_codes.type = "agent"` and `name = "match-advisor"` per brand (fallback brand `0`) for `prompt`, `model`, `tokens`, `temperature`, and optional encrypted `apiKey`.
- **Fallbacks** (when not set on the agent row):
  - model: `SettingName.matchAdvisorOpenAIModel` -> `SettingName.aiModel` -> `gpt-4o-mini`
  - apiKey: `OPENAI_API_KEY` env when no agent `apiKey` exists
- **Required**: `extra.prompt` on the `match-advisor` agent (brand-specific or brand `0`); the Lambda returns **503** if it is missing.
- **Output** (saved on `introductions.llm_match_advisor`): `initiatorPitch`, `responderPitch`, `hardContradictions`, and `assessment` (#84382):
  - `forA` / `forB`: a 1–5 score and a reason per compatibility topic, combined in code into `rawScoreForA/B` (0–100) and calibrated into `scoreForA/B` (#84383); `dealBreakerConflicts`, `missingInfo`, `staffNarrative`, `status`, `modelId`, `promptVersion`, `inputHash`, `partWeights`.
  - `freeText` (#2475, only when the prompt returns it): per direction the things the person asks for (Looking for and decline reasons) with the partner's own quoted words or `null`, `shown` / `of`, a `rating` and `points` computed in code; `conflicts` (one side's free text ruling out the other side's field, `clear` or `check`); `checks`; `pitchEvidence` (`answers` = receiver's Looking-for words, `backedBy` = described person's words); `exclusion`; `guard.droppedQuotes` and `guard.pitchBlocked`.
- **Code checks after the reply** (`applyMatchAdvisorGuards`, #2475):
  - Every quote must appear in what that person wrote (whole words, "…" allowed); others are dropped and counted.
  - The free-text rating comes from the count (`aiFreeTextRatingThresholds`, default `[0.8,0.6,0.4,0.2]`). A topic with key `freeTextFit`, if configured, is scored from that count, not by the model.
  - `aiFreeTextExclusionMode`: `flag` (default) adds a hard-contradiction line per clear free-text exclusion, so the introduction stays PENDING; `exclude` also sets that direction's AI score to 0; `off` keeps evidence only.
  - Member pitches mentioning a decline, Baal Teshuva / convert background or finances are blanked; the reason is stored in `freeText.guard.pitchBlocked`.
- **Precheck cache rows** (`ai_pair_assessment`): `profile_a` / `profile_b` are sorted ids; `raw_payload` holds the guarded reply from the initiator's side plus `initiatorProfileId` / `responderProfileId` for orientation. Raw (uncalibrated) scores.
- **Secrets**:
  - `general_codes.extra.apiKey` is expected encrypted at rest (`enc:v1:...`) and decrypted only at runtime.
  - decryption key source: `GENERAL_CODES_ENCRYPTION_KEY` (preferred) or `JWT_SECRET_KEY` fallback.

**Database**: apply migration `alove-docs/db-schema/migrations/add_llm_match_advisor_to_introductions.sql`.

#### findIncomingSuggestions
**Purpose**: Retrieves incoming match suggestions for a user
- **Handler**: `src/functions/findIncomingSuggestions.findIncomingSuggestionsHandler`
- **Path**: `/suggestions/incoming/{suggestionType}`
- **Method**: GET
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.suggestionType` - Type of suggestions to retrieve
  - `queryStringParameters.limit` (optional) - Number of suggestions to retrieve
  - `queryStringParameters.offset` (optional) - Pagination offset
- **Returns**:
  - `200` - Incoming suggestions retrieved successfully
  - `401` - Unauthorized
  - `404` - No suggestions found
  - `500` - Server error

#### findHistInSuggs
**Purpose**: Retrieves historical incoming suggestions for a user
- **Handler**: `src/functions/findHistoryIncomingSuggestions.findHistoryIncomingSuggestionsHandler`
- **Path**: `/suggestions/incoming/history`
- **Method**: GET
- **Timeout**: 15 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.limit` (optional) - Number of historical suggestions to retrieve
  - `queryStringParameters.offset` (optional) - Pagination offset
- **Returns**:
  - `200` - Historical suggestions retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

### Introduction Management Functions

#### replySuggestion
**Purpose**: Responds to a match suggestion (accept, decline, etc.)
- **Handler**: `src/functions/replySuggestion.replySuggestionHandler`
- **Path**: `/{interactionId}/reactions/{reaction}`
- **Method**: PUT
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction/suggestion
  - `pathParameters.reaction` - User's reaction (accept, decline, maybe)
- **Returns**:
  - `200` - Reaction recorded successfully
  - `400` - Invalid reaction
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### inspectSuggestion
**Purpose**: Inspects and analyzes a match suggestion
- **Handler**: `src/functions/inspectSuggestion.inspectSuggestionHandler`
- **Path**: `/{interactionId}/inspections/{type}`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction to inspect
  - `pathParameters.type` - Type of inspection to perform
  - `queryStringParameters.silent` (optional) - Whether to perform silent inspection
- **Returns**:
  - `200` - Inspection completed successfully
  - `400` - Invalid inspection type
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### extendsIntroduction
**Purpose**: Extends the duration of an introduction
- **Handler**: `src/functions/extendIntroduction.extendIntroducthionHandler`
- **Path**: `/introductions/{introductionId}/extends`
- **Method**: PUT
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction to extend
  - `body.extensionDays` (optional) - Number of days to extend by
- **Returns**:
  - `200` - Introduction extended successfully
  - `400` - Invalid extension period
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

### Termination and Reporting Functions

#### partyTerminateMatch
**Purpose**: Terminates a match by one of the parties
- **Handler**: `src/functions/partyTerminateMatch.partyTerminateMatchHandler`
- **Path**: `/{interactionId}/terminations`
- **Method**: PUT
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction to terminate
  - `body.reason` (optional) - Reason for termination
- **Returns**:
  - `200` - Match terminated successfully
  - `400` - Invalid termination request
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### setTerminationReason
**Purpose**: Sets the reason for terminating a match
- **Handler**: `src/functions/setTerminationReason.setTerminationReasonHandler`
- **Path**: `/{interactionId}/terminations/reasons`
- **Method**: PUT
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction
  - `body.reason` - Reason for termination
  - `body.details` (optional) - Additional details about the reason
- **Returns**:
  - `200` - Termination reason set successfully
  - `400` - Invalid reason
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### reportOnParty
**Purpose**: Reports inappropriate behavior by a user
- **Handler**: `src/functions/reportOnParty.reportOnPartyHandler`
- **Path**: `/{interactionId}/report`
- **Method**: POST
- **Timeout**: 30 seconds
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction
  - `body.reportedUserId` - ID of the user being reported
  - `body.reason` - Reason for the report
  - `body.evidence` (optional) - Supporting evidence
- **Returns**:
  - `200` - Report submitted successfully
  - `400` - Invalid report data
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

### Administrative Functions

#### adminTerminateMatchHandler
**Purpose**: Administratively terminates a match
- **Handler**: `src/functions/partyTerminateMatch.adminTerminateMatchHandler`
- **Path**: `/private/introductions/{interactionId}/terminations`
- **Method**: PUT
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction to terminate
  - `body.reason` - Administrative reason for termination
  - `body.adminId` - ID of the administrator
- **Returns**:
  - `200` - Match terminated successfully
  - `400` - Invalid termination request
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### adminFindHandler
**Purpose**: Finds introductions based on administrative criteria
- **Handler**: `src/functions/private/adminFindIntroductions.adminFindIntroductionsHandler`
- **Path**: `/private/introductions`
- **Method**: GET
- **Timeout**: 30 seconds
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.userId` (optional) - Filter by user ID
  - `queryStringParameters.status` (optional) - Filter by introduction status
  - `queryStringParameters.dateFrom` (optional) - Filter by start date
  - `queryStringParameters.dateTo` (optional) - Filter by end date
  - `queryStringParameters.limit` (optional) - Number of results to return
- **Returns**:
  - `200` - Introductions found successfully
  - `401` - Unauthorized
  - `500` - Server error

#### updateStatusIntroHandler
**Purpose**: Updates the status of an introduction
- **Handler**: `src/functions/private/updateStatusIntro.updateStatusIntroHandler`
- **Path**: `/private/introductions/{interactionId}/status`
- **Method**: PUT
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.interactionId` - ID of the interaction
  - `body.newStatus` - New status for the introduction
  - `body.reason` (optional) - Reason for status change
- **Returns**:
  - `200` - Status updated successfully
  - `400` - Invalid status
  - `401` - Unauthorized
  - `404` - Interaction not found
  - `500` - Server error

#### calculatePAHandler
**Purpose**: Calculates profile availability for a user
- **Handler**: `src/functions/calculateProfileAvaiablity.calculateProfileAvaiablityHandler`
- **Path**: `/private/profiles/{profileId}/availability`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profileId` - ID of the profile to calculate availability for
- **Returns**:
  - `200` - Availability calculated successfully
  - `400` - Invalid profile ID
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

### Scheduled Functions

#### termiIgnoredSuggestSchedule
**Purpose**: Scheduled function to terminate ignored suggestions
- **Handler**: `src/cron/terminateIgnoredSuggestions.terminateIgnoredSuggestionsScheduleHandler`
- **Timeout**: 60 seconds
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of ignored suggestions terminated

#### quietChatSchedule
**Purpose**: Scheduled function to handle quiet chat conversations
- **Handler**: `src/cron/quietChat.quietChatScheduleHandler`
- **Timeout**: 60 seconds
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of quiet chats processed

#### tryCreateIntroductions
**Purpose**: Scheduled function to attempt creating new introductions
- **Handler**: `src/cron/tryCreateIntroductions.tryCreateIntroductionsHandler`
- **Timeout**: 60 seconds
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of introductions created

#### systemShutDownOnOff
**Purpose**: Controls system shutdown mode
- **Handler**: `src/cron/systemShutDownOnOff.systemShutDownOnOff`
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: System shutdown status

## Environment Variables

The service uses the following environment variables:

- `CX_REPORTING_STRATEGY` - Coralogix reporting strategy
- `CX_DOMAIN` - Coralogix domain
- `CX_APPLICATION_NAME` - Coralogix application name
- `CX_SUBSYSTEM_NAME` - Coralogix subsystem name
- `CX_API_KEY` - Coralogix API key (from SSM)
- `WSS_API_GATEWAY_ENDPOINT` - WebSocket API Gateway endpoint

## Introduction Features

### Suggestion Types
- **Regular Suggestions**: Standard match suggestions
- **Premium Suggestions**: Enhanced suggestions for premium users
- **Compatibility Suggestions**: Suggestions based on deep compatibility analysis
- **Location-Based Suggestions**: Suggestions based on geographic proximity

### Introduction States
- **Pending**: Suggestion sent, waiting for response
- **Accepted**: Both parties accepted the introduction
- **Declined**: One or both parties declined
- **Expired**: Introduction expired without response
- **Terminated**: Introduction was terminated
- **Extended**: Introduction duration was extended

### Matchmaking Criteria
- **Compatibility Score**: Algorithm-based compatibility rating
- **Location**: Geographic proximity
- **Age Range**: Age compatibility preferences
- **Interests**: Shared interests and hobbies
- **Values**: Core values alignment
- **Communication Style**: Preferred communication methods

## Security Features

- **Authentication Required**: All endpoints require valid JWT tokens
- **Privacy Protection**: User data is anonymized in suggestions
- **Rate Limiting**: Protection against abuse of suggestion system
- **Content Moderation**: Reporting system for inappropriate behavior
- **Audit Logging**: All introduction activities are logged

## Error Handling

The service implements comprehensive error handling:

- **Validation Errors**: Invalid suggestion or introduction data
- **Authentication Errors**: Invalid or expired tokens
- **Authorization Errors**: Insufficient permissions
- **Not Found Errors**: Suggestions or introductions not found
- **Conflict Errors**: Conflicting introduction states
- **Service Errors**: External service failures

## Introduction status reference

Key terminal statuses (see `public.introduction_status` and `IntroductionStatus` in infra-lib):

| ID | Name | Notes |
|----|------|-------|
| 18 | ADMIN_REJECTED | Admin decline before send; never visible to end users; excluded from monthly intro limits |
| 25 | NOT_COUNTED | Admin marks an already-declined/ignored intro so it does not count toward monthly limits; visible in backoffice lists |

DB migration: `db-schema/migrations/add_not_counted_introduction_status.sql` (also in jlov-backend `db-scripts/sqlMigrations.sql`).

Monthly limit exclusion: `calculateProfileAvaiablity` treats `NOT_COUNTED` like `ADMIN_REJECTED` for `maxIntroductionsMonthly`.

## Integration Points

- **Profile Service**: User profile data for matching
- **Chat Service**: Communication after successful introductions
- **Notification Service**: User notifications for suggestions
- **Analytics Service**: Matchmaking algorithm optimization
- **Database**: Introduction and match data storage

## Monitoring and Logging

- **Coralogix Integration**: Centralized logging
- **Matchmaking Analytics**: Success rate tracking
- **Performance Monitoring**: CloudWatch metrics
- **Error Tracking**: Failed operations logging
- **User Behavior Analysis**: Introduction pattern analysis

## Scheduled Operations

### Daily Operations
- **Suggestion Generation**: Create new match suggestions
- **Expiration Cleanup**: Handle expired suggestions
- **Quiet Chat Processing**: Manage inactive conversations

### Weekly Operations
- **Compatibility Recalculation**: Update compatibility scores
- **User Activity Analysis**: Analyze user engagement patterns
- **System Health Checks**: Monitor system performance

### Monthly Operations
- **Algorithm Optimization**: Improve matching algorithms
- **Data Cleanup**: Remove old inactive data
- **Performance Review**: Analyze system performance metrics 