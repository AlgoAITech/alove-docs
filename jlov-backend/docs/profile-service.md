# Profile Service Documentation

## Service Overview

The Profile Service manages user profiles, photos, preferences, and profile-related operations in the JLOV dating platform. It handles profile creation, photo uploads, profile attributes, mood updates, snoozing functionality, and various administrative operations. The service provides comprehensive profile management capabilities for both regular users and administrators.

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
  - `body.brandId` - Brand identifier
  - `body.statusId` (optional) - Status filter
  - `body.internal` (optional) - Internal profiles filter
  - `body.sort` (optional) - Sort mode
- **Returns**:
  - `200` - Matching profile IDs and total count
  - `400` - Invalid/empty filter input
  - `500` - Query execution failure
- **Notes**:
  - Filters are split across `profiles.attributes_values`, `profiles.settings`, and `profile_external_info`
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