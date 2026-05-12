# Matchmakers Service Documentation

## Service Overview

The Matchmakers Service manages professional matchmaker functionality for the JLOV dating platform. It handles matchmaker profiles, introduction management, matchmaker-client relationships, and administrative operations for professional matchmaking services. The service provides tools for professional matchmakers to manage their clients and create curated introductions.

## Service Details

- **Runtime**: Node.js 22.x
- **Authentication**: AWS Cognito User Pools
- **Professional Services**: Matchmaker management and client relationships
- **Database**: Matchmaker and introduction database

## Lambda Functions

### Matchmaker Management Functions

#### getAvailableMMHandler
**Purpose**: Retrieves available matchmakers for users
- **Handler**: `src/functions/getAvailableMM.getAvailableMMHandler`
- **Path**: `/matchmakers`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.user` - User ID requesting matchmakers
  - `queryStringParameters.mmIds` (optional) - Specific matchmaker IDs to retrieve
- **Returns**:
  - `200` - Available matchmakers retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### getMatchmakersByIdsHandler
**Purpose**: Retrieves specific matchmakers by their IDs
- **Handler**: `src/functions/getMatchmakersByIds.getMatchmakersByIdsHandler`
- **Path**: `/matchmakers/byIds`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.matchmakerIds` - Comma-separated list of matchmaker IDs
  - `queryStringParameters.format` (optional) - Response format preference
- **Returns**:
  - `200` - Matchmakers retrieved successfully
  - `400` - Invalid matchmaker IDs
  - `401` - Unauthorized
  - `500` - Server error

#### getSingleMMHandler
**Purpose**: Retrieves a single matchmaker's profile
- **Handler**: `src/functions/getSingleMM.getSingleMMHandler`
- **Path**: `/matchmakers/{matchmakerId}`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.matchmakerId` - ID of the matchmaker to retrieve
- **Returns**:
  - `200` - Matchmaker profile retrieved successfully
  - `401` - Unauthorized
  - `404` - Matchmaker not found
  - `500` - Server error

#### createMatchmakerHandler
**Purpose**: Creates a new matchmaker profile
- **Handler**: `src/functions/createMatchmaker.createMatchmakerHandler`
- **Path**: `/matchmakers`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.matchmakerData` - Matchmaker profile information
  - `body.specializations` (optional) - Areas of expertise
  - `body.availability` (optional) - Availability schedule
- **Returns**:
  - `201` - Matchmaker created successfully
  - `400` - Invalid matchmaker data
  - `401` - Unauthorized
  - `409` - Matchmaker already exists
  - `500` - Server error

#### updateMatchmakerHandler
**Purpose**: Updates a matchmaker's profile information
- **Handler**: `src/functions/updateMatchmaker.updateMatchmakerHandler`
- **Path**: `/matchmakers/{matchmakerId}`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.matchmakerId` - ID of the matchmaker to update
  - `body.updateData` - Updated matchmaker information
- **Returns**:
  - `200` - Matchmaker updated successfully
  - `400` - Invalid update data
  - `401` - Unauthorized
  - `404` - Matchmaker not found
  - `500` - Server error

#### getMMregisterFormHandler
**Purpose**: Retrieves the registration form for new matchmakers
- **Handler**: `src/functions/getMMregisterForm.getMMregisterFormHandler`
- **Path**: `/mmForm`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None
- **Returns**:
  - `200` - Registration form retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

### Introduction Management Functions

#### getIntroductionsHandler
**Purpose**: Retrieves introductions managed by a matchmaker
- **Handler**: `src/functions/getIntroductions.getIntroductionsHandler`
- **Path**: `/introductions`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.matchmakerId` (optional) - Filter by matchmaker ID
  - `queryStringParameters.status` (optional) - Filter by introduction status
  - `queryStringParameters.page` (optional) - Page number for pagination
  - `queryStringParameters.limit` (optional) - Number of results per page
  - `queryStringParameters.before` (optional) - Filter introductions before this date
  - `queryStringParameters.after` (optional) - Filter introductions after this date
  - `queryStringParameters.brandId` (optional) - Filter by brand ID
  - `queryStringParameters.introId` (optional) - Specific introduction ID
  - `queryStringParameters.alreadyDated` (optional) - Filter by dating status
  - `queryStringParameters.mmStatuses` (optional) - Filter by matchmaker statuses
- **Returns**:
  - `200` - Introductions retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### getFullIntroductionHandler
**Purpose**: Retrieves complete details of a specific introduction
- **Handler**: `src/functions/getFullIntroduction.getFullIntroductionHandler`
- **Path**: `/introductions/{introductionId}`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction to retrieve
- **Returns**:
  - `200` - Introduction details retrieved successfully
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

#### updateStatusHandler
**Purpose**: Updates the status of an introduction
- **Handler**: `src/functions/updateIntroductionStatus.updateIntroductionStatusHandler`
- **Path**: `/introductions/{introductionId}/status`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction to update
  - `body.newStatus` - New status for the introduction
  - `body.reason` (optional) - Reason for status change
- **Returns**:
  - `200` - Status updated successfully
  - `400` - Invalid status
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

**Relationship milestone duplicate handling**:
- When moving an introduction to `DATING`, `ENGAGED`, or `MARRIED`, the service first closes older active duplicate introductions for the same profile pair as `TERMINATED`.
- This keeps the database duplicate-introduction trigger from blocking valid milestone updates when legacy/imported data contains more than one active introduction for the same couple.
- Closed duplicates keep a status-change MM log and `statusReason` metadata pointing to the introduction that superseded them.

#### requestChangeHandler
**Purpose**: Requests a change to an introduction
- **Handler**: `src/functions/requestIntroductionChange.requestIntroductionChangeHandler`
- **Path**: `/introductions/{introductionId}/change`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction to change
  - `body.changeRequest` - Details of the requested change
  - `body.reason` - Reason for the change request
- **Returns**:
  - `200` - Change request submitted successfully
  - `400` - Invalid change request
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

#### declineIntroductionHandler
**Purpose**: Declines an introduction
- **Handler**: `src/functions/declineIntroduction.declineIntroductionHandler`
- **Path**: `/introductions/{introductionId}/decline`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction to decline
  - `body.reason` (optional) - Reason for declining
- **Returns**:
  - `200` - Introduction declined successfully
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

#### addIntroductionCommentHandler
**Purpose**: Adds a comment to an introduction
- **Handler**: `src/functions/addIntroductionComment.addIntroductionCommentHandler`
- **Path**: `/introductions/{introductionId}/comment`
- **Method**: POST
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.introductionId` - ID of the introduction
  - `body.comment` - Comment text to add
  - `body.commentType` (optional) - Type of comment (internal, client-facing, etc.)
- **Returns**:
  - `201` - Comment added successfully
  - `400` - Invalid comment data
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

### Administrative Functions

#### adminSetActionHandler
**Purpose**: Sets administrative actions for matchmakers
- **Handler**: `src/functions/adminSetAction.adminSetActionHandler`
- **Path**: `/private/action`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.matchmakerId` - ID of the matchmaker
  - `body.action` - Administrative action to perform
  - `body.reason` (optional) - Reason for the action
- **Returns**:
  - `200` - Action performed successfully
  - `400` - Invalid action
  - `401` - Unauthorized
  - `404` - Matchmaker not found
  - `500` - Server error

#### adminGetMMListHandler
**Purpose**: Retrieves list of matchmakers for administrative purposes
- **Handler**: `src/functions/getAvailableMM.adminGetMMListHandler`
- **Path**: `/admin/matchmakers`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.status` (optional) - Filter by matchmaker status
  - `queryStringParameters.limit` (optional) - Number of results to return
  - `queryStringParameters.offset` (optional) - Pagination offset
- **Returns**:
  - `200` - Matchmaker list retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### adminGetIntroStatsHandler
**Purpose**: Retrieves introduction statistics for administrative purposes
- **Handler**: `src/functions/adminGetStats.adminGetIntroStatsHandler`
- **Path**: `/admin/stats`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.dateFrom` (optional) - Start date for statistics
  - `queryStringParameters.dateTo` (optional) - End date for statistics
  - `queryStringParameters.matchmakerId` (optional) - Filter by specific matchmaker
- **Returns**:
  - `200` - Statistics retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### adminGetMMStatsHandler
**Purpose**: Retrieves matchmaker performance statistics
- **Handler**: `src/functions/adminGetStats.adminGetMMStatsHandler`
- **Path**: `/admin/matchmakers/stats`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.dateFrom` (optional) - Start date for statistics
  - `queryStringParameters.dateTo` (optional) - End date for statistics
- **Returns**:
  - `200` - Matchmaker statistics retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### adminSingleStatsHandler
**Purpose**: Retrieves statistics for a single matchmaker
- **Handler**: `src/functions/adminGetStats.adminGetSingleMMStatsHandler`
- **Path**: `/admin/matchmakers/{matchmakerId}/stats`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `pathParameters.matchmakerId` - ID of the matchmaker
  - `queryStringParameters.dateFrom` (optional) - Start date for statistics
  - `queryStringParameters.dateTo` (optional) - End date for statistics
- **Returns**:
  - `200` - Single matchmaker statistics retrieved successfully
  - `401` - Unauthorized
  - `404` - Matchmaker not found
  - `500` - Server error

### Event Management Functions

#### addMMEventHandler
**Purpose**: Adds events related to matchmaker activities
- **Handler**: `src/functions/addMMEvent.addMMEventHandler`
- **Path**: `/events`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.matchmakerId` - ID of the matchmaker
  - `body.eventType` - Type of event
  - `body.eventData` - Event details
  - `body.timestamp` (optional) - Event timestamp
- **Returns**:
  - `201` - Event added successfully
  - `400` - Invalid event data
  - `401` - Unauthorized
  - `500` - Server error

### Utility Functions

#### isUserExsitsHandler
**Purpose**: Checks if a user exists in the system
- **Handler**: `src/functions/isUserExsits.isUserExsitsHandler`
- **Path**: `/isUserExsits`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.userId` - ID of the user to check
  - `queryStringParameters.email` (optional) - Email to check
- **Returns**:
  - `200` - User existence check completed
  - `401` - Unauthorized
  - `500` - Server error

#### authMMHandler
**Purpose**: Handles authentication for matchmaker-specific operations
- **Handler**: `src/utils/authMM.authMMHandler`
- **Trigger**: Internal authentication middleware
- **Parameters**:
  - `event.requestContext.authorizer` - User authentication data
  - `event.requestContext.authorizer.claims` - User claims
- **Returns**: Authentication result and user context

### Scheduled Functions

#### sendRemindersHandler
**Purpose**: Sends reminders to matchmakers and clients
- **Handler**: `src/functions/cron/sendReminders.sendRemindersHandler`
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of reminders sent

#### reviveMatchmakerHandler
**Purpose**: Revives inactive matchmakers
- **Handler**: `src/functions/cron/reviveMatchmaker.reviveMatchmakerHandler`
- **Trigger**: CloudWatch Events (scheduled)
- **Parameters**:
  - `event.time` - Current execution time
- **Returns**: Number of matchmakers revived

## Environment Variables

The service uses the following environment variables:

- `CX_REPORTING_STRATEGY` - Coralogix reporting strategy
- `CX_DOMAIN` - Coralogix domain
- `CX_APPLICATION_NAME` - Coralogix application name
- `CX_SUBSYSTEM_NAME` - Coralogix subsystem name
- `CX_API_KEY` - Coralogix API key (from SSM)
- `WSS_API_GATEWAY_ENDPOINT` - WebSocket API Gateway endpoint

## Matchmaker Features

### Matchmaker Types
- **Professional Matchmakers**: Certified professional matchmakers
- **Specialized Matchmakers**: Matchmakers with specific expertise areas
- **Regional Matchmakers**: Matchmakers serving specific geographic areas
- **Premium Matchmakers**: High-tier matchmakers with advanced features

### Introduction States
- **Pending**: Introduction created, waiting for matchmaker review
- **In Progress**: Matchmaker is actively working on the introduction
- **Completed**: Introduction has been successfully completed
- **Cancelled**: Introduction was cancelled
- **On Hold**: Introduction temporarily paused

### Matchmaker Capabilities
- **Client Management**: Manage multiple client relationships
- **Introduction Creation**: Create curated introductions
- **Progress Tracking**: Track introduction progress and outcomes
- **Communication Tools**: Tools for communicating with clients
- **Analytics**: Performance and success rate analytics

### Introduction → Matchmakers Assignment

The `introductions` table stores matchmaker assignment in the JSONB column
`matchmakers` (source of truth):

```json
{
  "current": [11, 12],
  "next": [13]
}
```

- `current` — matchmakers actively responsible for the intro (see, edit, get
  notified). Length is typically 1; with the brand setting `multiMMS` it may
  be more than one.
- `next` — queue used when an MM declines: the first id is promoted into
  `current`, replacing the declining MM.

The legacy comma-separated column `matchmaker_id` (`"11,12,13"`) is kept and
mirrored from `matchmakers` only because already-deployed mobile builds still
read it. New backend logic must treat `matchmakers` as authoritative. Once the
mobile rollout completes the legacy column and the `matchmakerId` field on
`UserIntroduction` will be removed.

**Migration**: backfill the new column from the legacy string per brand using
the backoffice CLI:

```bash
pnpm run cli copy-introductions-matchmaker-id-to-jsonb <brandId> [--use-next] [--dry-run]
```

`--use-next` matches the new "first id is responsible, rest queued" semantics
(first id → `current`, rest → `next`). Without the flag all ids land in
`current`.

## Security Features

- **Authentication Required**: All endpoints require valid JWT tokens
- **Role-Based Access**: Different permissions for matchmakers and administrators
- **Client Privacy**: Protection of client information and preferences
- **Audit Logging**: All matchmaker activities are logged
- **Data Validation**: Input validation for all matchmaker data

## Error Handling

The service implements comprehensive error handling:

- **Validation Errors**: Invalid matchmaker or introduction data
- **Authentication Errors**: Invalid or expired tokens
- **Authorization Errors**: Insufficient permissions
- **Not Found Errors**: Matchmakers or introductions not found
- **Conflict Errors**: Conflicting introduction states
- **Service Errors**: External service failures

## Integration Points

- **User Service**: User profile and authentication data
- **Profile Service**: Client profile information
- **Introductions Service**: Introduction lifecycle management
- **Chat Service**: Communication between matchmakers and clients
- **Notification Service**: Reminders and notifications
- **Analytics Service**: Performance tracking and reporting

## Monitoring and Logging

- **Coralogix Integration**: Centralized logging
- **Performance Analytics**: Matchmaker success rate tracking
- **Client Satisfaction**: Client feedback and satisfaction metrics
- **Error Tracking**: Failed operations logging
- **Activity Monitoring**: Matchmaker activity patterns

## Scheduled Operations

### Daily Operations
- **Reminder Processing**: Send daily reminders to matchmakers and clients
- **Status Updates**: Update introduction statuses
- **Activity Tracking**: Track matchmaker activity levels

### Weekly Operations
- **Performance Review**: Analyze matchmaker performance metrics
- **Client Check-ins**: Automated client satisfaction surveys
- **System Health Checks**: Monitor system performance

### Monthly Operations
- **Success Rate Analysis**: Analyze introduction success rates
- **Matchmaker Evaluation**: Evaluate matchmaker performance
- **Client Retention Analysis**: Analyze client retention patterns 