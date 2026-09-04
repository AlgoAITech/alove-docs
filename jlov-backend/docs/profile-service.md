# Profile Service Documentation

## Service Overview

The Profile Service manages user profiles, photos, preferences, and profile-related operations in the JLOV dating platform. It handles profile creation, photo uploads, profile attributes, mood updates, snoozing functionality, and various administrative operations. The service provides comprehensive profile management capabilities for both regular users and administrators.

### Email links with `NextScreenEvent.backOffice`

Operational emails (communications sent via `profile-service` notifications) may use the **`backOffice`** next-screen action. For those emails, `NEXT_LINK` / `DECLINE_LINK` are built from the brand **`matchmakerUrl`** setting.

When the brand has the app feature **`matchmakerMobileApp`** set to `true` in `public.settings` (same pattern as other `AppFeatures` flags), links use the static page **`/bo-redirect.html`** with the target backoffice path in the **`link`** query parameter (URL-encoded). That page opens the native Matchmaker app on mobile when possible (`bomobile://open?link=...`) and falls back to the web backoffice on desktop or if the app does not open.

If **`matchmakerMobileApp`** is not `true` for the brand, email links are **web-only**: `{matchmakerUrl}/#<path>` (HashRouter) with no app bridge.

For **BOEmails** events `customerSupportTicketAssigned` and `customerSupportGuestAdminReply`, the profile service may set `NEXT_LINK` to the same rules as above, with path `/tickets/{ticketSource}/{ticketId}` (numeric `ticketSource` matches `TicketSource` in the backoffice) when the event payload includes `ticketId` and `ticketSource`.

## Service Details

- **Runtime**: Node.js 22.x
- **Authentication**: AWS Cognito User Pools
- **External Integrations**: S3 for photo storage, Kinesis for events
- **Database**: Profile database

## Lambda Functions

### Profile Management Functions

#### getProfile
**Purpose**: Retrieves a user's profile information
- **Handler**: `src/functions/getProfile_V2.getProfileV2Handler`
- **Path**: `/profile/{userID}`
- **Method**: GET
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.userID` - ID of the user whose profile to retrieve
- **Returns**:
  - `200` - Profile retrieved successfully
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

#### createProfileV2
**Purpose**: Creates a new user profile
- **Handler**: `src/functions/createProfile_V2.createProfileV2Handler`
- **Path**: `/profiles`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.userId` - User ID for the new profile
  - `body.profileData` - Profile information object
  - `body.brandId` (optional) - Brand identifier
- **Returns**:
  - `201` - Profile created successfully
  - `400` - Invalid profile data
  - `401` - Unauthorized
  - `409` - Profile already exists
  - `500` - Server error

#### saveProfileAttriibutes
**Purpose**: Saves or updates profile attributes
- **Handler**: `src/functions/saveProfileAttriibutes.saveProfileAttriibutesHandler`
- **Path**: `/profileAttributes`
- **Method**: POST
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.profileId` - Profile ID
  - `body.attributes` - Object containing attributes to save
- **Returns**:
  - `200` - Attributes saved successfully
  - `400` - Invalid attributes
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error
- **Sensitive attributes tokenization**:
  - When `SENSITIVE_ATTR_SEARCH_SECRET` is configured, sensitive attribute search tokens are computed from the original submitted values.
  - Masked storage values like `["hidden"]` are never used as the token source.
  - This keeps backoffice free-text sensitive search accurate after profile updates and questionnaire response saves.

### Photo Management Functions

#### uploadPhotoBase64
**Purpose**: Uploads a photo to a user's profile using base64 encoding
- **Handler**: `src/functions/uploadPhotoBase64.uploadPhotoBase64Handler`
- **Path**: `/{profileID}/photos`
- **Method**: POST
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profileID` - Profile ID
  - `body.photoData` - Base64 encoded photo data
  - `body.photoType` (optional) - Type of photo
  - `body.order` (optional) - Display order
- **Returns**:
  - `201` - Photo uploaded successfully
  - `400` - Invalid photo data
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

#### getUserPhoto
**Purpose**: Retrieves photos for a specific profile
- **Handler**: `src/functions/getUserPhotos.getUserPhotoHandler`
- **Path**: `/{profileID}/photos`
- **Method**: GET
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profileID` - Profile ID
  - `queryStringParameters.includeDeleted` (optional) - Include deleted photos
- **Returns**:
  - `200` - Photos retrieved successfully
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

#### updatePhotoStatus
**Purpose**: Updates the status of a photo (approve, reject, etc.)
- **Handler**: `src/functions/updateImageStatus.updateImageStatusHandler`
- **Path**: `/{profileID}/photos/{imageID}`
- **Method**: PUT
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profileID` - Profile ID
  - `pathParameters.imageID` - Image ID
  - `body.status` - New status for the photo
  - `body.reason` (optional) - Reason for status change
- **Returns**:
  - `200` - Photo status updated successfully
  - `400` - Invalid status
  - `401` - Unauthorized
  - `404` - Photo not found
  - `500` - Server error

#### updateImageOrder
**Purpose**: Updates the display order of photos
- **Handler**: `src/functions/updateImageOrder.updateImageOrderHandler`
- **Path**: `/updatePhotos`
- **Method**: PUT
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.profileId` - Profile ID
  - `body.photoOrder` - Array of photo IDs in desired order
- **Returns**:
  - `200` - Photo order updated successfully
  - `400` - Invalid order data
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

### User State Management Functions

#### updateMood
**Purpose**: Updates a user's current mood
- **Handler**: `src/functions/updateMood.updateMoodHandler`
- **Path**: `/mood`
- **Method**: PUT
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.mood` - New mood value
  - `body.profileId` (optional) - Profile ID (uses authenticated user if not provided)
- **Returns**:
  - `200` - Mood updated successfully
  - `400` - Invalid mood
  - `401` - Unauthorized
  - `500` - Server error

#### startSnoozing
**Purpose**: Starts snoozing mode for a user (temporarily hides profile)
- **Handler**: `src/functions/startSnoozing.startSnoozingHandler`
- **Path**: `/me/snooze/start`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.duration` (optional) - Snooze duration in hours
  - `body.reason` (optional) - Reason for snoozing
- **Returns**:
  - `200` - Snoozing started successfully
  - `400` - Invalid duration
  - `401` - Unauthorized
  - `500` - Server error

#### stopSnoozing
**Purpose**: Stops snoozing mode for a user
- **Handler**: `src/functions/stopSnoozing.stopSnoozingHandler`
- **Path**: `/me/snooze/stop`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None (uses authenticated user context)
- **Returns**:
  - `200` - Snoozing stopped successfully
  - `401` - Unauthorized
  - `404` - User not snoozing
  - `500` - Server error

### Account Management Functions

#### setScheduleForDeletionUser
**Purpose**: Schedules a user account for deletion
- **Handler**: `src/functions/setScheduleForDeletionUser.setScheduleForDeletionUserHandler`
- **Path**: `/me`
- **Method**: DELETE
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.deletionDate` (optional) - Date when account should be deleted
  - `body.reason` (optional) - Reason for deletion
- **Returns**:
  - `200` - Deletion scheduled successfully
  - `400` - Invalid deletion date
  - `401` - Unauthorized
  - `500` - Server error

#### recoverDeletedUser
**Purpose**: Recovers a user account that was scheduled for deletion
- **Handler**: `src/functions/recoverDeletedUser.recoverDeletedUserHandler`
- **Path**: `/me/recover`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None (uses authenticated user context)
- **Returns**:
  - `200` - Account recovered successfully
  - `401` - Unauthorized
  - `404` - Account not scheduled for deletion
  - `500` - Server error

### Settings and Preferences Functions

#### updatePersonalSettings
**Purpose**: Updates a user's personal settings
- **Handler**: `src/functions/updatePersonalSettings.updatePesonalSettingsHandler`
- **Path**: `/settings`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.settings` - Object containing settings to update
- **Returns**:
  - `200` - Settings updated successfully
  - `400` - Invalid settings
  - `401` - Unauthorized
  - `500` - Server error

#### updateCommunicationSettings
**Purpose**: Updates a user's communication preferences
- **Handler**: `src/functions/communicationSettings.updateCommunicationSettingsHandler`
- **Path**: `/communicationSettings`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.communicationSettings` - Communication preferences object
- **Returns**:
  - `200` - Communication settings updated successfully
  - `400` - Invalid settings
  - `401` - Unauthorized
  - `500` - Server error

#### getProfileResponses
**Purpose**: Retrieves a user's profile questionnaire responses
- **Handler**: `src/functions/getProfileResponses.getProfileResponsesHandler`
- **Path**: `/me/responses`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None (uses authenticated user context)
- **Returns**:
  - `200` - Responses retrieved successfully
  - `401` - Unauthorized
  - `404` - No responses found
  - `500` - Server error

### Administrative Functions

#### adminSendPushNotification
**Purpose**: Sends a push notification to a specific user (administrative function)
- **Handler**: `src/functions/private/adminSendPushNotification.adminSendPushNotificationHandler`
- **Path**: `/private/push-notification/{userId}`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.userId` - Target user ID
  - `body.message` - Notification message
  - `body.title` (optional) - Notification title
  - `body.data` (optional) - Additional notification data
- **Returns**:
  - `200` - Notification sent successfully
  - `400` - Invalid notification data
  - `401` - Unauthorized
  - `404` - User not found
  - `500` - Server error

#### moderateImage
**Purpose**: Moderates a user's uploaded image (administrative function)
- **Handler**: `src/functions/private/moderateImage.handler`
- **Path**: `/private/moderateImage`
- **Method**: POST
- **Timeout**: 60 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.imageId` - Image ID to moderate
  - `body.action` - Moderation action (approve, reject, flag)
  - `body.reason` (optional) - Reason for moderation action
- **Returns**:
  - `200` - Image moderated successfully
  - `400` - Invalid moderation action
  - `401` - Unauthorized
  - `404` - Image not found
  - `500` - Server error

**LLM settings source**:
- The moderation LLM config is resolved from `general_codes` with:
  - `type = "agent"`
  - `name = "image-moderation"`
- Supported `extra` fields:
  - `prompt`
  - `model`
  - `tokens`
  - `temperature`
  - `apiKey` (stored encrypted as `enc:v1:...` in DB, decrypted only at runtime)
- Fallback behavior:
  - If no DB row/field exists, handler falls back to legacy defaults (`moderatorPrompt`, `gpt-5-mini`, env `OPENAI_API_KEY`).

#### updateProfileAttribute
**Purpose**: Updates a specific profile attribute (administrative function)
- **Handler**: `src/functions/private/updateProfileAttribute.handler`
- **Path**: `/private/updateAttribute`
- **Method**: PUT
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.profileId` - Profile ID
  - `body.attribute` - Attribute name to update
  - `body.value` - New attribute value
- **Returns**:
  - `200` - Attribute updated successfully
  - `400` - Invalid attribute or value
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

### Utility Functions

#### ping
**Purpose**: Health check endpoint for the service
- **Handler**: `src/functions/ping.pingHandler`
- **Path**: `/ping`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None
- **Returns**:
  - `200` - Service is healthy
  - `401` - Unauthorized
  - `500` - Service error

#### predictor
**Purpose**: Returns legacy `attachmentResult` for a profile. When it is missing, the service first writes per–question-category predictor averages for downstream matching (meeplus_ai), then fills `attachmentResult` via the existing DB function for frontend compatibility.
- **Handler**: `src/functions/getPredictor.getPredictorHandler`
- **Path**: `/predictor/{profile_id}`
- **Method**: GET
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profile_id` - Profile ID
- **Computation** (when `attachmentResult` is missing):
  1. Loads the latest `profile_responses` per `batch_content_id` joined to `question` where `question_type = 3` (predictor) and `response_type` is scale only.
  2. Averages numeric answers by `question.question_category_id` and upserts `profile_external_info`: `attribute_name` = category id (string), `attribute_value` = average, `source` = `predictorsCalc` (for meeplus_ai / dynamic scoring only).
  3. Calls `public.predictor_attachmentCalc(profile_id)` so `attachmentResult` is populated as before for legacy clients.
- **Returns**:
  - `200` - `{ attribute_value }` for `attachmentResult` when present after read or DB function; may be null if the function did not write a row
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error
- **Side effect - AI predictor descriptions**: on both the cached and the computed path the handler also calls
  `ensurePredictorDescriptionsAiStored` (`src/functions/private/generatePredictorDescriptionsAi.ts`), wrapped in
  `try/catch` so a failure never affects the response. It is a no-op when the descriptions already exist, when the
  profile has no `brand_id`, when the brand has no active `predictor-descriptions` agent
  (`general_codes`, `type = agent`), or when the profile has no predictor scale answers. Otherwise it calls the
  brand's OpenAI agent and stores two `profile_external_info` rows,
  `source = predictorDescriptionsAi`: `predictorDescriptionsUser` (member-facing, in the profile's language) and
  `predictorDescriptionsAdminEn` (English, for admin/BO tooling).

##### Context sent to the `predictor-descriptions` agent

The user message is a single JSON object. Its shape matters because the agent's prompt is written against it:

| Field | Source | Why |
|-------|--------|-----|
| `userLanguage` | `profile.settings.language`, else `Accept-Language`, else `en` | Language of the member-facing text |
| `questionnaire[].questionId` / `namedId` / `questionText` | `question` + `translations` (question language, English fallback) | The predictor items themselves |
| `questionnaire[].responseType` / `response` | latest `profile_responses` row per `batch_content_id` | The member's raw scale answers |
| `questionnaire[].isDealBreaker` | `question.is_deal_breaker` | Lets the model weight deal-breaker items differently from ordinary ones |
| `questionnaire[].axis` | `general_codes.name` for `question.question_category_id` (`type = questionCategory`) | Names the axis an item scores (anxiety, avoidance, ...) instead of a raw category id |
| `labelMatrix[]` | `general_codes.extra.labelCalculation` on `type = factor` rows, via `loadPredictorLabelMatrix(brandId)` | The same ceiling bands BO uses to derive attachment-style labels |

`labelMatrix` rows are `{ factor, axis1, axis2, bands: [{ label, axis1_min, axis1_max, axis2_min, axis2_max }] }`.
They are built with the **same** helpers (`parseFactorLabelCalculation`, `predictorCategoryPairByFactor`) that
`predictorsCalcFromResponses.ts` uses to compute stored factor labels, so the narrative the AI writes and the
label BO shows are derived from one source of truth. Without it the model had to guess thresholds from raw
scores and would read a mid-scale answer (e.g. 3.5 out of 7) as strongly indicative of an axis even when the
brand's configured bands say it is not. Axis names are resolved to `general_codes.name`, never raw ids -
edit the bands in BO (predictor relations / factor label calculation) and the AI context follows automatically.

Stored descriptions can be cleared and regenerated from the backoffice
(`regeneratePredictorDescriptionsAi`), which deletes the two rows and re-triggers `GET /predictor/{profile_id}`.

#### policyAttribute
**Purpose**: Handles policy-related attribute changes
- **Handler**: `src/functions/attributePolicyChange.attributePolicyChangeHandler`
- **Path**: `/policyAttribute`
- **Method**: POST
- **Timeout**: 20 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.profileId` - Profile ID
  - `body.policyType` - Type of policy change
  - `body.attributes` - Attributes affected by policy
- **Returns**:
  - `200` - Policy attribute updated successfully
  - `400` - Invalid policy data
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

### Event Processing Functions

#### kinesisEventsCollector
**Purpose**: Collects and processes user events from Kinesis streams
- **Handler**: `src/functions/kinesisEventsCollector.kinesisEventsCollectorHandler`
- **Path**: `/event`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.events` - Array of user events to process
- **Returns**:
  - `200` - Events processed successfully
  - `400` - Invalid event data
  - `401` - Unauthorized
  - `500` - Server error

#### consumeUserEvents
**Purpose**: Processes user events for analytics and tracking
- **Handler**: `src/functions/consumeUserEvents.consumeUserEventsHandler`
- **Timeout**: 30 seconds
- **Parameters**:
  - `event.Records` - Array of event records to process
- **Returns**: Success/failure status for event processing

### Scheduled Functions

#### deleteUsersSchedule
**Purpose**: Scheduled function to delete users marked for deletion
- **Handler**: `src/functions/private/deleteScheduledUsers.deleteScheduledUsersHandler`
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of users deleted

#### stopSnoozingSchedule
**Purpose**: Scheduled function to stop snoozing for expired snooze periods
- **Handler**: `src/functions/private/stopSnoozingSchedule.stopSnoozingScheduleHandler`
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of snooze periods ended

#### processTagRules
**Purpose**: Processes tag rules for profile categorization
- **Handler**: `src/functions/private/processTagRules.processTagRulesHandler`
- **Path**: `/private/tag-rules/{ruleId}/process`
- **Method**: POST
- **Timeout**: 300 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.ruleId` - Tag rule ID to process
- **Returns**:
  - `200` - Tag rule processed successfully
  - `400` - Invalid rule
  - `401` - Unauthorized
  - `404` - Rule not found
  - `500` - Server error

#### processStaleAgePreferenceBump
**Purpose**: Daily job that increases the **upper bound** of partner age range answers when the member’s latest questionnaire answer for that step is older than one year. Keeps matching profiles aligned without requiring the user to reopen settings.

- **Handler**: `src/functions/private/processStaleAgePreferenceBump.processStaleAgePreferenceBumpHandler`
- **Trigger**: CloudWatch Events — daily at **02:30 UTC** (`cron(30 2 * * ? *)`)
- **Timeout**: 900 seconds
- **Behavior**:
  1. Resolves active `batch_content` rows joined to `question` where `question_type` is preference (`Pref`) and `profile_attr` matches partner age preference — canonical storage key **`prefAge`** (also **`agePref`** and names containing `age` + `pref` for legacy/other configs).
  2. For each active brand, finds the **latest** `profile_responses` row per `(profile_id, batch_content_id)` where `COALESCE(reported, created)` is older than one year.
  3. Parses partner age range from `response.a1` as **`[minAge, maxAge]`** (two numbers), increases **max** by 1 (capped by `question.range_max` when set), inserts a **new** `profile_responses` row with `skip_reason_id = 2`, and updates `profiles.attributes_values` for the question’s `profile_attr` using the same tuple shape when stored as two numbers, or legacy `"min-max"` string form when present.

### Specialized Functions

#### profileLookupHandler
**Purpose**: Performs private, advanced profile filtering for backoffice `/profiles/byAttributes` flows
- **Handler**: `src/functions/profileLookup.profileLookupHandler`
- **Path**: `/private/profileLookup`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.filter` - Array of attribute filter conditions
  - `body.operator` - Logical operator (`AND` or `OR`)
  - `body.page` - Pagination page (0-based)
  - `body.pageSize` (optional) - Page size for SQL `LIMIT`/`OFFSET` (default **200**, clamped **1–500**). Backoffice typically sends **200**; matchmaker mobile singles browse sends **10**.
  - When the API includes a total hit count, profile rows in the JSON array may carry **`full_count`** (total matching profiles for the current filter query). The matchmaker **bo_mobile** singles list reads this on the first page **from the raw response before dropping internal-test or disallowed-status rows**, so the header total matches backoffice `TablePage` (`rows[0]?.full_count`); clients should not assume every endpoint or page includes it.
  - `body.brandId` - Brand identifier
  - `body.statusId` (optional) - Status filter
  - `body.internal` (optional) - Internal profiles filter
  - `body.sort` (optional) - Sort mode
- **Returns**:
  - `200` - Matching profile IDs and total count
  - `400` - Invalid/empty filter input
  - `500` - Query execution failure
- **Notes**:
  - Pagination uses `LIMIT pageSize OFFSET page * pageSize` (contiguous pages; no skipped rows between pages).
  - Filters are split across `profiles.attributes_values`, `profiles.settings`, and `profile_external_info`
  - Profile-attribute metadata controls special routing only. Requested attributes with no metadata row are still treated as `profiles.attributes_values` filters so they are not silently dropped.
  - Attribute `settings.searchAlso` expands one filter into an OR group across the source attribute and its configured alternate attributes; separate filters such as `gender` remain separate top-level conditions.
  - External attribute matching is case-insensitive on `profile_external_info.attribute_name`
  - Attributes that exist in `profile_external_info` for the brand are treated as external even when profile-attribute metadata is missing

#### createSiblingHandler
**Purpose**: Creates a sibling profile for a user
- **Handler**: `src/functions/createSibling.createSiblingHandler`
- **Path**: `/siblings`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.parentProfileId` - Parent profile ID
  - `body.siblingData` - Sibling profile information
- **Returns**:
  - `201` - Sibling profile created successfully
  - `400` - Invalid sibling data
  - `401` - Unauthorized
  - `409` - Sibling already exists
  - `500` - Server error

#### getMyChildsHandler
**Purpose**: Retrieves child profiles for a parent user
- **Handler**: `src/functions/getMyChilds.getMyChildsHandler`
- **Path**: `/childs`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.parentId` - Parent profile ID
- **Returns**:
  - `200` - Child profiles retrieved successfully
  - `401` - Unauthorized
  - `404` - No children found
  - `500` - Server error

#### openTicketHandler
**Purpose**: Opens a support ticket for a user
- **Handler**: `src/functions/openTicket.openTicketHandler`
- **Path**: `/ticket`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.subject` - Ticket subject
  - `body.message` - Ticket message
  - `body.category` (optional) - Ticket category
  - `body.priority` (optional) - Ticket priority
- **Returns**:
  - `201` - Ticket created successfully
  - `400` - Invalid ticket data
  - `401` - Unauthorized
  - `500` - Server error

#### openTicketGuestHandler
**Purpose**: Opens a support ticket for a guest user (no authentication required)
- **Handler**: `src/functions/openTicket.openTicketHandler`
- **Path**: `/ticket/guest`
- **Method**: POST
- **CORS**: true
- **Parameters**:
  - `body.email` - Guest email address
  - `body.subject` - Ticket subject
  - `body.message` - Ticket message
  - `body.category` (optional) - Ticket category
- **Returns**:
  - `201` - Ticket created successfully
  - `400` - Invalid ticket data
  - `500` - Server error

#### uploadFileHandler
**Purpose**: Uploads files for administrative purposes
- **Handler**: `src/functions/uploadFile.uploadFileHandler`
- **Path**: `/private/uploadFile`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.fileData` - File data (base64 encoded)
  - `body.fileName` - Name of the file
  - `body.fileType` - Type of the file
- **Returns**:
  - `200` - File uploaded successfully
  - `400` - Invalid file data
  - `401` - Unauthorized
  - `500` - Server error

#### adminStartSnoozeHandler
**Purpose**: Administratively starts snoozing for a user
- **Handler**: `src/functions/startSnoozing.adminStartSnoozeHandler`
- **Path**: `/private/{profileId}/snooze`
- **Method**: PUT
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.profileId` - Profile ID to snooze
  - `body.duration` (optional) - Snooze duration in hours
  - `body.reason` (optional) - Reason for snoozing
- **Returns**:
  - `200` - Snoozing started successfully
  - `400` - Invalid duration
  - `401` - Unauthorized
  - `404` - Profile not found
  - `500` - Server error

## Environment Variables

The service uses the following environment variables:

- `CX_REPORTING_STRATEGY` - Coralogix reporting strategy
- `CX_DOMAIN` - Coralogix domain
- `CX_APPLICATION_NAME` - Coralogix application name
- `CX_SUBSYSTEM_NAME` - Coralogix subsystem name
- `CX_API_KEY` - Coralogix API key (from SSM)
- `WSS_API_GATEWAY_ENDPOINT` - WebSocket API Gateway endpoint

## Profile Management Features

### Profile Types
- **Regular Profiles**: Standard dating profiles
- **Child Profiles**: Profiles for users under parental supervision
- **Sibling Profiles**: Related profiles within the same family

### Profile States
- **Active**: Profile is visible and can receive matches
- **Snoozed**: Profile is temporarily hidden
- **Scheduled for Deletion**: Profile marked for future deletion
- **Deleted**: Profile has been permanently removed

### Photo Management
- **Upload**: Base64 encoded photo uploads
- **Moderation**: Administrative photo approval/rejection
- **Ordering**: Custom photo display order
- **Status Tracking**: Photo approval status management
- **HEIC / HEIF in `getProfilePhoto`**: Objects in S3 may be HEIC even when the key ends in `.jpg`. The profile service decodes HEIC with `heic-decode` (WASM) and re-encodes to JPEG before applying watermarks with Sharp, because the Lambda Sharp build does not ship libheif and would otherwise throw `No decoding plugin installed for this compression format`.

## Security Features

- **Authentication Required**: All endpoints require valid JWT tokens
- **Photo Moderation**: Administrative review of uploaded photos
- **Privacy Controls**: Snoozing functionality for temporary profile hiding
- **Data Validation**: Input validation for all profile data
- **Audit Logging**: All profile operations are logged

## Error Handling

The service implements comprehensive error handling:

- **Validation Errors**: Invalid input data
- **Authentication Errors**: Invalid or expired tokens
- **Authorization Errors**: Insufficient permissions
- **Not Found Errors**: Profile or resource not found
- **Conflict Errors**: Duplicate data or conflicting operations
- **Service Errors**: External service failures

## Integration Points

- **S3**: Photo storage and file uploads
- **Kinesis**: User event processing
- **CloudWatch Events**: Scheduled operations
- **Database**: Profile and attribute storage
- **Push Notifications**: User notification system

## Monitoring and Logging

- **Coralogix Integration**: Centralized logging
- **Event Processing**: Kinesis stream processing
- **Performance Monitoring**: CloudWatch metrics
- **Error Tracking**: Failed operations logging
- **Audit Trail**: Profile management operations logging 