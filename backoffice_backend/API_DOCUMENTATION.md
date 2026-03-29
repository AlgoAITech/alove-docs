# Backoffice Backend API Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Authentication & Authorization](#authentication--authorization)
4. [API Endpoints](#api-endpoints)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)

## Project Overview

The Backoffice Backend is a multi-tenant NestJS application designed to manage dating/matchmaking platform operations. It provides comprehensive administrative tools for managing user profiles, content, communications, customer support, and business operations across multiple brands.

### Main Purpose
- **Multi-tenant Management**: Supports multiple brands (100, 101, 102, 103) with isolated data and operations
- **User Profile Management**: Complete lifecycle management of user profiles including status, attributes, and interactions
- **Content Management**: Multi-language content, translations, and media asset management
- **Customer Support**: Ticket management, reporting, and support workflows
- **Business Intelligence**: Analytics, reporting, and dashboard functionality
- **Communication Management**: Email, SMS, and push notification systems
- **AI Integration**: AI simulations and automated responses

### Key Features
- Role-based access control with granular permissions
- Multi-language support with translation management
- Real-time session tracking and activity monitoring
- File upload and management via AWS S3
- Integration with external services (Twilio, BigQuery, OpenAI)
- Batch processing and automation capabilities

## Architecture

### Technology Stack
- **Framework**: NestJS (Node.js)
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with refresh tokens
- **File Storage**: AWS S3
- **External Services**: 
  - Twilio (SMS/Communication)
  - BigQuery (Analytics)
  - OpenAI (AI features)
  - AWS Cognito (Identity management)
  - AWS DynamoDB (NoSQL storage)
  - AWS Kinesis (Stream processing)
  - AWS SQS (Message queuing)

### Multi-Tenant Architecture
The application uses a **brand-based multi-tenant architecture**:

1. **Main Router**: Routes requests to appropriate brand instances based on `brandID` parameter
2. **Brand Instances**: Each brand runs on a separate port (base port + brandId)
3. **Data Isolation**: Each brand has isolated data through database filtering
4. **Shared Infrastructure**: Common codebase with brand-specific configurations

### Port Configuration
- Main Router: `process.env.PORT`
- Brand 100: `process.env.PORT + 100`
- Brand 101: `process.env.PORT + 101`
- Brand 102: `process.env.PORT + 102`
- Brand 103: `process.env.PORT + 103`

### Core Modules
- **Database Module**: TypeORM configuration and connection management
- **Auth Module**: Authentication and session management
- **Content Module**: Multi-language content and translation management
- **Profile Module**: User profile lifecycle management
- **Communication Module**: Email, SMS, and notification services
- **Customer Support Module**: Ticket and support management
- **Analytics Module**: Reporting and business intelligence
- **Settings Module**: Application configuration management

## Authentication & Authorization

### Authentication Flow
1. **Login**: POST `/api/auth/` with email/password
2. **Token Generation**: JWT access token (15min) + refresh token (7 days)
3. **Token Refresh**: POST `/api/auth/refresh` with refresh token
4. **Session Tracking**: Automatic session creation and activity monitoring

### Authorization Levels
1. **AuthGuard**: Basic authentication check
2. **RolesGuard**: Role-based permission verification
3. **EntityGuard**: Entity-level access control

### Permission System
- **Page-based**: Access to specific application pages
- **Action-based**: CRUD operations (Add, Edit, Delete, Access)
- **Brand-specific**: Permissions scoped to specific brands

### Access Numbers (Permission Categories)
- `ViewQuestion`: Question management
- `AdminSettings`: Administrative settings
- `AISimulations`: AI simulation features
- And more granular permissions for each module

## API Endpoints

### Authentication Endpoints

#### POST `/api/auth/`
**Purpose**: User login
**Authentication**: None
**Parameters**:
```json
{
  "email": "string",
  "password": "string"
}
```
**Response**:
```json
{
  "success": true,
  "user": {
    "id": "number",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "brands": "object",
    "role": "object",
    "isActive": "boolean"
  },
  "token": "Bearer <jwt_token>"
}
```

#### POST `/api/auth/refresh`
**Purpose**: Refresh access token
**Authentication**: Refresh token (cookie or body)
**Parameters**:
```json
{
  "refreshToken": "string" // optional if in cookie
}
```
**Response**:
```json
{
  "token": "Bearer <new_jwt_token>"
}
```

#### POST `/api/auth/activity-ping`
**Purpose**: Update user activity
**Authentication**: AuthGuard
**Parameters**:
```json
{
  "lastActivity": "number"
}
```

#### GET `/api/auth/checkAuth`
**Purpose**: Verify authentication status
**Authentication**: Bearer token
**Response**: User object or error

#### GET `/api/auth/logOut`
**Purpose**: Logout user
**Response**: `{ "auth": false, "token": null }`

### Profile Management Endpoints

#### GET `/api/profiles`
**Purpose**: Get profiles with filtering
**Authentication**: EntityGuard
**Query Parameters**:
- `statusId`: Profile status filter
- `brandId`: Brand filter
- `limit`: Pagination limit
- `offset`: Pagination offset
- `search`: Search term
- `groupId`: Group filter

#### GET `/api/profiles/:id`
**Purpose**: Get specific profile
**Authentication**: EntityGuard
**Parameters**:
- `id`: Profile ID (UUID)

#### PUT `/api/profiles/:id`
**Purpose**: Update profile
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Profile ID
**Body**: Profile update data

#### DELETE `/api/profiles/:id`
**Purpose**: Delete profile
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Profile ID

### Content Management Endpoints

#### GET `/api/contents`
**Purpose**: Get content items
**Authentication**: AuthGuard + EntityGuard
**Query Parameters**:
- `statusId`: Content status
- `typeId`: Content type
- `langId`: Language filter

#### POST `/api/contents`
**Purpose**: Create new content
**Authentication**: AuthGuard + RolesGuard
**Body**: Content creation data

#### PUT `/api/contents/:id`
**Purpose**: Update content
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Content ID
**Body**: Content update data

#### DELETE `/api/contents/:id`
**Purpose**: Delete content
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Content ID

#### GET `/api/general-codes`
**Purpose**: Get general codes by type
**Authentication**: RolesGuard + Access(GeneralCodesSettings)
**Query Parameters**:
- `type`: General code type (optional; supports comma-separated values)
- `lang`: Language code for translated code names (optional)

#### General Code type `agent` (LLM prompt management)
The backend supports a dedicated `general_codes.type = "agent"` for LLM configuration.

Use `general_codes.name` as a unique key and store settings in `general_codes.extra`:

```json
{
  "prompt": "You are a SQL generator ...",
  "model": "gpt-4.1-mini",
  "tokens": 2000,
  "temperature": 0.1,
  "apiKey": "sk-..."
}
```

Current keys used by reports query generation:
- `reports-system-main-db` (base prompt/settings for Main DB reports)
- `reports-system-bigquery` (base prompt/settings for BigQuery reports)
- `reports-type-<reportType>` (optional type-specific override, e.g. `reports-type-user-growth`)

Resolution order:
1. Type-level agent (`reports-type-<reportType>`)
2. Source-level base agent (`reports-system-main-db` / `reports-system-bigquery`)
3. Legacy file prompts (`src/prompts/reports/*.txt`) as fallback

Model/tokens/temperature/apiKey are read from `extra` (type-level overrides base-level values).

`apiKey` handling:
- On create/update via backoffice API, `extra.apiKey` is encrypted before being stored.
- On read, API returns a masked representation (`first 10 chars + "***"`), never the full key.
- Backend runtime decrypts the key only when making LLM calls.

#### POST `/api/general-codes/auto-update-profile/trigger`
**Purpose**: Manually trigger the daily Auto Update Profile lambda job
**Authentication**: RolesGuard + Access(GeneralCodesSettings, Edit)
**Body**: None
**Response**:
```json
{
  "success": true,
  "functionName": "profile-service-<stage>-processAutoUpdateProfile",
  "statusCode": 202,
  "requestId": "aws-request-id"
}
```
**Notes**:
- This is an async invoke (`InvocationType: Event`) and returns after queueing.
- Function name can be overridden by `AUTO_UPDATE_PROFILE_FUNCTION_NAME` or `PROFILE_SERVICE_AUTO_UPDATE_PROFILE_FUNCTION_NAME`.

### Screen Management Endpoints

#### GET `/api/screens`
**Purpose**: Get screens/pages
**Authentication**: AuthGuard + EntityGuard
**Query Parameters**:
- `statusId`: Screen status
- `langId`: Language filter

#### POST `/api/screens`
**Purpose**: Create new screen
**Authentication**: AuthGuard + RolesGuard
**Body**: Screen creation data

#### PUT `/api/screens/:id`
**Purpose**: Update screen
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Screen ID
**Body**: Screen update data

#### DELETE `/api/screens/:id`
**Purpose**: Delete screen
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Screen ID

### Communication Endpoints

#### GET `/api/comms`
**Purpose**: Get communications
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `typeId`: Communication type
- `statusId`: Status filter

#### POST `/api/comms`
**Purpose**: Create communication
**Authentication**: AuthGuard + RolesGuard
**Body**: Communication data

#### PUT `/api/comms/:id`
**Purpose**: Update communication
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Communication ID
**Body**: Update data

#### DELETE `/api/comms/:id`
**Purpose**: Delete communication
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Communication ID

### Customer Support Endpoints

#### GET `/api/customer-support/tickets`
**Purpose**: Get support tickets
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `statusId`: Ticket status
- `priorityId`: Priority level
- `profileId`: Profile filter

#### POST `/api/customer-support/tickets`
**Purpose**: Create support ticket
**Authentication**: AuthGuard + RolesGuard
**Body**: Ticket creation data

#### PUT `/api/customer-support/tickets/:id`
**Purpose**: Update ticket
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Ticket ID
**Body**: Ticket update data

#### GET `/api/customer-support/reports`
**Purpose**: Get abuse reports
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `statusId`: Report status
- `profileId`: Profile filter

### Settings Endpoints

#### GET `/api/settings`
**Purpose**: Get application settings
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `key`: Setting key filter

#### POST `/api/settings`
**Purpose**: Create/update setting
**Authentication**: AuthGuard + RolesGuard
**Body**: Setting data

#### PUT `/api/settings/:id`
**Purpose**: Update specific setting
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Setting ID
**Body**: Setting update data

### Role Management Endpoints

#### GET `/api/roles`
**Purpose**: Get user roles
**Authentication**: EntityGuard + RolesGuard
**Query Parameters**:
- `brandId`: Brand filter

#### POST `/api/roles`
**Purpose**: Create role
**Authentication**: EntityGuard + RolesGuard
**Body**: Role creation data

#### PUT `/api/roles/:id`
**Purpose**: Update role
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Role ID
**Body**: Role update data

#### DELETE `/api/roles/:id`
**Purpose**: Delete role
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Role ID

### Group Management Endpoints

#### GET `/api/groups`
**Purpose**: Get user groups
**Authentication**: EntityGuard
**Query Parameters**:
- `brandId`: Brand filter

#### POST `/api/groups`
**Purpose**: Create group
**Authentication**: EntityGuard + RolesGuard
**Body**: Group creation data

#### PUT `/api/groups/:id`
**Purpose**: Update group
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Group ID
**Body**: Group update data

#### DELETE `/api/groups/:id`
**Purpose**: Delete group
**Authentication**: EntityGuard + RolesGuard
**Parameters**:
- `id`: Group ID

### Question Management Endpoints

#### GET `/api/questions`
**Purpose**: Get questions
**Authentication**: AuthGuard + EntityGuard
**Query Parameters**:
- `typeId`: Question type
- `statusId`: Status filter

#### POST `/api/questions`
**Purpose**: Create question
**Authentication**: AuthGuard + RolesGuard
**Body**: Question creation data

#### PUT `/api/questions/:id`
**Purpose**: Update question
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Question ID
**Body**: Question update data

#### DELETE `/api/questions/:id`
**Purpose**: Delete question
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Question ID

### Translation Endpoints

#### GET `/api/translations`
**Purpose**: Get translations
**Authentication**: AuthGuard + EntityGuard
**Query Parameters**:
- `langId`: Language filter
- `statusId`: Translation status

#### POST `/api/translations`
**Purpose**: Create translation
**Authentication**: AuthGuard + RolesGuard
**Body**: Translation data

#### PUT `/api/translations/:id`
**Purpose**: Update translation
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Translation ID
**Body**: Translation update data

### Dashboard Endpoints

#### GET `/api/dashboard/stats`
**Purpose**: Get dashboard statistics
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `period`: Time period
- `brandId`: Brand filter

#### GET `/api/dashboard/analytics`
**Purpose**: Get analytics data
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `metric`: Analytics metric
- `dateRange`: Date range filter

### Reports Endpoints

#### GET `/api/reports`
**Purpose**: Get reports
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `typeId`: Report type
- `dateRange`: Date range
- `brandId`: Brand filter

#### POST `/api/reports/generate`
**Purpose**: Generate new report
**Authentication**: AuthGuard + RolesGuard
**Body**: Report generation parameters

### AI Simulation Endpoints

#### GET `/api/ai-simulations`
**Purpose**: Get AI simulations
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `statusId`: Simulation status
- `typeId`: Simulation type

#### POST `/api/ai-simulations`
**Purpose**: Create AI simulation
**Authentication**: AuthGuard + RolesGuard
**Body**: Simulation data

#### PUT `/api/ai-simulations/:id`
**Purpose**: Update AI simulation
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Simulation ID
**Body**: Simulation update data

### Batch Processing Endpoints

#### GET `/api/batch/triggers`
**Purpose**: Get batch triggers
**Authentication**: AuthGuard + RolesGuard
**Query Parameters**:
- `statusId`: Trigger status
- `typeId`: Trigger type

#### POST `/api/batch/triggers`
**Purpose**: Create batch trigger
**Authentication**: AuthGuard + RolesGuard
**Body**: Trigger data

#### PUT `/api/batch/triggers/:id`
**Purpose**: Update batch trigger
**Authentication**: AuthGuard + RolesGuard
**Parameters**:
- `id`: Trigger ID
**Body**: Trigger update data

### Utility Endpoints

#### GET `/api/utils/health`
**Purpose**: Health check
**Authentication**: None
**Response**: Service status

#### POST `/api/utils/upload`
**Purpose**: File upload
**Authentication**: AuthGuard + RolesGuard
**Body**: Multipart form data
**Response**: Uploaded file information

## Data Models

### Core Entities

#### Profile
- **Primary Key**: `profileId` (UUID)
- **Key Fields**:
  - `userId`: User identifier
  - `brandId`: Brand association
  - `statusId`: Profile status
  - `attributesValues`: Profile attributes
  - `settings`: User settings
  - `plan`: Subscription plan
  - `tokens`: Available tokens

#### Content
- **Primary Key**: `id`
- **Key Fields**:
  - `typeId`: Content type
  - `statusId`: Content status
  - `langId`: Language
  - `translations`: Multi-language content

#### Screen
- **Primary Key**: `id`
- **Key Fields**:
  - `statusId`: Screen status
  - `translations`: Multi-language content
  - `settings`: Screen configuration

#### BoUser (System User)
- **Primary Key**: `id`
- **Key Fields**:
  - `email`: User email
  - `role`: Role assignments
  - `brands`: Brand access
  - `isActive`: Account status

#### BoRole
- **Primary Key**: `id`
- **Key Fields**:
  - `permissions`: Role permissions
  - `brandId`: Brand association

### Relationship Models

#### Introduction
- Links two profiles for matching
- Tracks introduction status and interactions

#### Ticket
- Customer support tickets
- Links to profiles and support agents

#### Group
- User grouping system
- Many-to-many with profiles

## Error Handling

### Global Exception Filter
The application uses a global exception filter that:
- Catches all unhandled exceptions
- Logs errors with full context
- Returns user-friendly error responses
- Preserves sensitive information in logs only

### Error Response Format
```json
{
  "statusCode": 400,
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/profiles",
  "method": "GET",
  "message": "Error description"
}
```

### Common HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

### Authentication Errors
- Missing token: 401
- Invalid token: 401
- Expired token: 401
- Insufficient permissions: 403

### Validation Errors
- Invalid input data: 400
- Missing required fields: 400
- Invalid file format: 400

## Security Considerations

### CORS Configuration
- Restricted to `*.a-dmin.ai` domains
- Localhost allowed for development
- Credentials enabled

### JWT Security
- Access tokens expire in 15 minutes
- Refresh tokens expire in 7 days
- Secure cookie settings for refresh tokens
- HTTP-only cookies in production

### Rate Limiting
- Request logging for monitoring
- Session tracking for activity
- IP-based request correlation

### Data Protection
- Password hashing with MD5 (consider upgrading to bcrypt)
- Sensitive data filtering in responses
- Secure file upload validation
- SQL injection prevention via TypeORM

## Deployment

### Environment Variables
- `PORT`: Base port for main router
- `JWT_SECRET_KEY`: JWT signing key
- `JWT_SECRET_REFRESH_KEY`: Refresh token signing key
- `ENV`: Environment (dev/prod)
- Database connection strings
- AWS credentials
- External service API keys

### Docker Support
- Multi-stage build configuration
- Environment-specific configurations
- Health check endpoints

### Monitoring
- Winston logging integration
- Request/response logging
- Error tracking and alerting
- Performance monitoring
- Session activity tracking 