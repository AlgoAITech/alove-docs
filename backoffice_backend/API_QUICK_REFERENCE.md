# API Quick Reference Guide

## Authentication
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/` | None | Login |
| POST | `/api/auth/refresh` | Refresh Token | Refresh access token |
| POST | `/api/auth/activity-ping` | AuthGuard | Update activity |
| GET | `/api/auth/checkAuth` | Bearer Token | Verify auth status |
| GET | `/api/auth/logOut` | None | Logout |

## Profile Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/profiles` | EntityGuard | Get profiles |
| GET | `/api/profiles/:id` | EntityGuard | Get specific profile |
| PUT | `/api/profiles/:id` | EntityGuard + RolesGuard | Update profile |
| DELETE | `/api/profiles/:id` | EntityGuard + RolesGuard | Delete profile |
| POST | `/api/profiles/:id/link-parent-child` | EntityGuard + RolesGuard (ViewEndUser + BManager) | Link parent/child: body `{ "mode": "linkChild" \| "linkParent", "targetProfileOrUserId": "<uuid>" }` (target by profile ID or user ID, same brand). Updates `parent_user_id`, `attributes_values` (`familyId`, `isChild`, `userType`), and child Cognito `custom:parent` (aligned with profile-service `createSibling` / `makePrimaryAccount`). |

## Content Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/contents` | AuthGuard + EntityGuard | Get content |
| POST | `/api/contents` | AuthGuard + RolesGuard | Create content |
| PUT | `/api/contents/:id` | AuthGuard + RolesGuard | Update content |
| DELETE | `/api/contents/:id` | AuthGuard + RolesGuard | Delete content |
| POST | `/api/general-codes/auto-update-profile/trigger` | RolesGuard + Access(GeneralCodesSettings, Edit) | Manually trigger the daily auto-update-profile lambda |

## Screen Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/screens` | AuthGuard + EntityGuard | Get screens |
| POST | `/api/screens` | AuthGuard + RolesGuard | Create screen |
| PUT | `/api/screens/:id` | AuthGuard + RolesGuard | Update screen |
| DELETE | `/api/screens/:id` | AuthGuard + RolesGuard | Delete screen |

## Communication
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/comms` | AuthGuard + RolesGuard | Get communications |
| POST | `/api/comms` | AuthGuard + RolesGuard | Create communication |
| PUT | `/api/comms/:id` | AuthGuard + RolesGuard | Update communication |
| DELETE | `/api/comms/:id` | AuthGuard + RolesGuard | Delete communication |
| POST | `/api/comms/:id/send` | RolesGuard + Access(ViewCommunication, Edit) | Send now or schedule one-time communication |
| POST | `/api/comms/:id/send/profiles` | RolesGuard + Access(ViewCommunication, Edit) | Queue one-time communication for specific profile IDs (optional delay); applies OneTime profile-status filter from comm param when configured |

## Customer Support
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/customer-support/tickets` | AuthGuard + RolesGuard | Get tickets |
| POST | `/api/customer-support/tickets` | AuthGuard + RolesGuard | Create ticket |
| PUT | `/api/customer-support/tickets/:id` | AuthGuard + RolesGuard | Update ticket |
| POST | `/api/customerSupport/:id/cursor-agent` | RolesGuard + Access(CustomerSupportTicketView, Edit) | Launch Cursor cloud agent using latest `developerInstructions` from request body or saved ticket extra |
| GET | `/api/customer-support/reports` | AuthGuard + RolesGuard | Get reports |

## Settings
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/settings` | AuthGuard + RolesGuard | Get settings |
| POST | `/api/settings` | AuthGuard + RolesGuard | Create/update setting |
| PUT | `/api/settings/:id` | AuthGuard + RolesGuard | Update setting |

## Role Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/roles` | EntityGuard + RolesGuard | Get roles |
| POST | `/api/roles` | EntityGuard + RolesGuard | Create role |
| PUT | `/api/roles/:id` | EntityGuard + RolesGuard | Update role |
| DELETE | `/api/roles/:id` | EntityGuard + RolesGuard | Delete role |

## Group Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/groups` | EntityGuard | Get groups |
| POST | `/api/groups` | EntityGuard + RolesGuard | Create group |
| PUT | `/api/groups/:id` | EntityGuard + RolesGuard | Update group |
| DELETE | `/api/groups/:id` | EntityGuard + RolesGuard | Delete group |

## Question Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/questions` | AuthGuard + EntityGuard | Get questions |
| POST | `/api/questions` | AuthGuard + RolesGuard | Create question |
| PUT | `/api/questions/:id` | AuthGuard + RolesGuard | Update question |
| DELETE | `/api/questions/:id` | AuthGuard + RolesGuard | Delete question |

## Translation Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/translations` | AuthGuard + EntityGuard | Get translations |
| POST | `/api/translations` | AuthGuard + RolesGuard | Create translation |
| PUT | `/api/translations/:id` | AuthGuard + RolesGuard | Update translation |

## Dashboard
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/dashboard/stats` | AuthGuard + RolesGuard | Get statistics |
| GET | `/api/dashboard/analytics` | AuthGuard + RolesGuard | Get analytics |

## Reports
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/reports` | AuthGuard + RolesGuard | Get reports |
| POST | `/api/reports/generate` | AuthGuard + RolesGuard | Generate report |

## Reports Management
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/reports-management/generate-raw-query` | RolesGuard + Access(10.1) | Generate raw SQL and, when `reportId` is provided, persist both `config.rawQuery` and `config.rawQueryPrompt` in the report |

## AI Simulations
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/ai-simulations` | AuthGuard + RolesGuard | Get simulations |
| POST | `/api/ai-simulations` | AuthGuard + RolesGuard | Create simulation |
| PUT | `/api/ai-simulations/:id` | AuthGuard + RolesGuard | Update simulation |

## Batch Processing
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/batch/triggers` | AuthGuard + RolesGuard | Get triggers |
| POST | `/api/batch/triggers` | AuthGuard + RolesGuard | Create trigger |
| PUT | `/api/batch/triggers/:id` | AuthGuard + RolesGuard | Update trigger |

## Utilities
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/utils/health` | None | Health check |
| POST | `/api/utils/upload` | AuthGuard + RolesGuard | File upload |

## Common Query Parameters

### Pagination
- `limit`: Number of items per page
- `offset`: Number of items to skip

### Filtering
- `statusId`: Filter by status
- `brandId`: Filter by brand
- `typeId`: Filter by type
- `langId`: Filter by language
- `search`: Search term

### Date Filtering
- `dateRange`: Date range filter
- `period`: Time period
- `fromDate`: Start date
- `toDate`: End date

## Authentication Types

### None
- No authentication required
- Public endpoints

### AuthGuard
- Basic JWT token authentication
- Validates user identity

### EntityGuard
- Entity-level access control
- Filters data by brand/entity

### RolesGuard
- Role-based permission verification
- Checks user permissions for specific actions

### Combined Guards
- Multiple guards can be applied together
- All guards must pass for access

## Common Response Formats

### Success Response
```json
{
  "data": {...},
  "success": true
}
```

### Error Response
```json
{
  "statusCode": 400,
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/endpoint",
  "method": "GET",
  "message": "Error description"
}
```

### Paginated Response
```json
{
  "data": [...],
  "total": 100,
  "limit": 10,
  "offset": 0,
  "hasMore": true
}
```

## Brand Configuration

### Supported Brands
- Brand 100: Port = BASE_PORT + 100
- Brand 101: Port = BASE_PORT + 101
- Brand 102: Port = BASE_PORT + 102
- Brand 103: Port = BASE_PORT + 103

### Brand Selection
- Query parameter: `?brandID=100`
- Header: `X-brand: 100`
- Default: Brand 100

## Rate Limits & Security

### CORS
- Allowed origins: `*.a-dmin.ai`
- Development: `localhost`
- Credentials: Enabled

### JWT Tokens
- Access token: 15 minutes
- Refresh token: 7 days
- Secure cookies in production

### Request Logging
- All requests logged with correlation ID
- Error tracking and monitoring
- Session activity tracking 