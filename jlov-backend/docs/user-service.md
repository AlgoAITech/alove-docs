# User Service Documentation

## Service Overview

The User Service manages user accounts, personal information, and user-related operations in the JLOV dating platform. It handles user profile creation, personal information management, child user accounts, and administrative user operations. The service provides both public APIs for authenticated users and private APIs for administrative functions.

## Service Details

- **Runtime**: Node.js 22.x
- **Authentication**: AWS Cognito User Pools
- **External Integrations**: ALOVE API, S3 for assets
- **Database**: User account database

## Lambda Functions

### Public User Functions

#### savePersonalInfoHandler
**Purpose**: Saves or updates a user's personal information
- **Handler**: `src/functions/savePersonalInfo.savePersonalInfoHandler`
- **Path**: `/personal-info`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.firstName` (optional) - User's first name
  - `body.lastName` (optional) - User's last name
  - `body.dateOfBirth` (optional) - User's date of birth
  - `body.gender` (optional) - User's gender
  - `body.location` (optional) - User's location
  - `body.preferences` (optional) - User preferences object
- **Returns**:
  - `200` - Personal info saved successfully
  - `400` - Invalid data
  - `401` - Unauthorized
  - `500` - Server error

#### getPersonalInfoHandler
**Purpose**: Retrieves a user's personal information
- **Handler**: `src/functions/getPersonalInfo.getPersonalInfoHandler`
- **Path**: `/personal-info`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None (uses authenticated user context)
- **Returns**:
  - `200` - Personal info retrieved successfully
  - `401` - Unauthorized
  - `404` - User not found
  - `500` - Server error

#### setChildPasswordHandler
**Purpose**: Sets or updates password for a child user account
- **Handler**: `src/functions/setChildPassword.setChildPasswordHandler`
- **Path**: `/childs/password`
- **Method**: PUT
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.childUserId` - ID of the child user
  - `body.newPassword` - New password for child account
  - `body.confirmPassword` - Password confirmation
- **Returns**:
  - `200` - Password updated successfully
  - `400` - Invalid password or mismatch
  - `401` - Unauthorized
  - `404` - Child user not found
  - `500` - Server error

### Private Administrative Functions

#### createChildUserHandler
**Purpose**: Creates a new child user account (administrative function)
- **Handler**: `src/functions/private/createChildUser.createChildUserHandler`
- **Path**: `/childs`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.parentUserId` - ID of the parent user
  - `body.childInfo` - Child user information object
  - `body.brandId` (optional) - Brand identifier
- **Returns**:
  - `201` - Child user created successfully
  - `400` - Invalid data
  - `401` - Unauthorized
  - `409` - User already exists
  - `500` - Server error

#### updateUserAttributesHandler
**Purpose**: Updates user attributes (administrative function)
- **Handler**: `src/functions/private/updateUserAttributes.updateUserAttributesHandler`
- **Path**: `/users`
- **Method**: PUT
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.userId` - ID of the user to update
  - `body.attributes` - Object containing attributes to update
- **Returns**:
  - `200` - Attributes updated successfully
  - `400` - Invalid attributes
  - `401` - Unauthorized
  - `404` - User not found
  - `500` - Server error

#### getUsersByFilter
**Purpose**: Retrieves users based on filter criteria (administrative function)
- **Handler**: `src/functions/private/getUserFilter.getUserFilterHandler`
- **Path**: `/private/filter`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.filter` - Filter criteria
  - `queryStringParameters.limit` (optional) - Maximum number of results
  - `queryStringParameters.offset` (optional) - Pagination offset
- **Returns**:
  - `200` - Users retrieved successfully
  - `400` - Invalid filter
  - `401` - Unauthorized
  - `500` - Server error

#### adminDeleteUserByIds
**Purpose**: Deletes multiple users by their IDs (administrative function)
- **Handler**: `src/functions/private/adminDeleteUserByIds.adminDeleteUserByIdsHandler`
- **Path**: `/private`
- **Method**: DELETE
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.userIds` - Array of user IDs to delete
  - `body.reason` (optional) - Reason for deletion
- **Returns**:
  - `200` - Users deleted successfully
  - `400` - Invalid user IDs
  - `401` - Unauthorized
  - `500` - Server error

#### getUsersByIds
**Purpose**: Retrieves multiple users by their IDs (administrative function)
- **Handler**: `src/functions/private/getUsersByIds.getUsersByIdsHandler`
- **Path**: `/private`
- **Method**: GET
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.ids` - Comma-separated list of user IDs
  - `queryStringParameters.userPool` (optional) - User pool identifier
  - `queryStringParameters.withParentInfo` (optional) - Include parent information
- **Returns**:
  - `200` - Users retrieved successfully
  - `400` - Invalid user IDs
  - `401` - Unauthorized
  - `500` - Server error

**Behavior notes**:
- Missing IDs are treated as a partial-success case: the endpoint returns only users that were found.
- When one or more requested IDs are missing, the service now emits a single aggregated info log that includes:
  - requested count
  - missing count
  - missing ID list

### Parent-Child Relationship Functions

#### addParentEmailHandler
**Purpose**: Adds a parent's email to a child user account
- **Handler**: `src/functions/addParentEmail.handler`
- **Path**: `/add-parent-email`
- **Method**: POST
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.childUserId` - ID of the child user
  - `body.parentEmail` - Parent's email address
- **Returns**:
  - `200` - Parent email added successfully
  - `400` - Invalid email
  - `401` - Unauthorized
  - `409` - Email already exists
  - `500` - Server error

#### verifyParentEmailHandler
**Purpose**: Verifies a parent's email address
- **Handler**: `src/functions/verifyParentEmail.handler`
- **Path**: `/verify-parent-email`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.token` - Verification token
  - `queryStringParameters.childUserId` - Child user ID
- **Returns**:
  - `200` - Email verified successfully
  - `400` - Invalid or expired token
  - `401` - Unauthorized
  - `500` - Server error

## Environment Variables

The service uses the following environment variables:

- `AWS_NODEJS_CONNECTION_REUSE_ENABLED` - Enable connection reuse
- `ENVIROMENT` - Deployment environment
- `ALOVE_API_BASE_URL` - External API base URL
- `ALOVE_API_KEY` - External API key (from SSM)
- `ASSETS_BUCKET` - S3 bucket for assets
- `ACCOUNT_DB_HOST` - Database host
- `ACCOUNT_DB_USER` - Database username
- `ACCOUNT_DB_PASSWORD` - Database password (from SSM)
- `JWT_SECRET` - JWT signing secret (from SSM)
- `USER_EVENTS_QUEUE_URL` - SQS queue for user events
- `CX_REPORTING_STRATEGY` - Coralogix reporting strategy
- `CX_DOMAIN` - Coralogix domain
- `CX_APPLICATION_NAME` - Coralogix application name
- `CX_SUBSYSTEM_NAME` - Coralogix subsystem name
- `CX_API_KEY` - Coralogix API key (from SSM)

## User Management Features

### User Types
- **Regular Users**: Standard dating platform users
- **Child Users**: Users under parental supervision
- **Parent Users**: Users who manage child accounts

### User Attributes
- **Personal Information**: Name, date of birth, gender, location
- **Preferences**: Dating preferences and settings
- **Account Status**: Active, suspended, deleted
- **Parent-Child Relationships**: Links between parent and child accounts

## Security Features

- **Authentication Required**: All endpoints require valid JWT tokens
- **Role-Based Access**: Different permissions for regular users and administrators
- **Parental Controls**: Special handling for child user accounts
- **Data Validation**: Input validation for all user data
- **Audit Logging**: All user operations are logged

## Error Handling

The service implements comprehensive error handling:

- **Validation Errors**: Invalid input data
- **Authentication Errors**: Invalid or expired tokens
- **Authorization Errors**: Insufficient permissions
- **Not Found Errors**: User or resource not found
- **Conflict Errors**: Duplicate data or conflicting operations
- **Service Errors**: External service failures

## Integration Points

- **AWS Cognito**: User authentication and management
- **ALOVE API**: External user data integration
- **S3**: Asset storage for user-related files
- **SQS**: User event processing
- **Database**: User account and relationship storage

## Monitoring and Logging

- **Coralogix Integration**: Centralized logging
- **User Events**: SQS queue for user activity tracking
- **Performance Monitoring**: CloudWatch metrics
- **Error Tracking**: Failed operations logging
- **Audit Trail**: User management operations logging 