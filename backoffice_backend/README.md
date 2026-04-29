# Backoffice Backend Documentation

Welcome to the comprehensive documentation for the Backoffice Backend API. This documentation provides detailed information about the project's architecture, API endpoints, authentication, and usage.

## 📚 Documentation Index

### [API Documentation](./API_DOCUMENTATION.md)
Complete API documentation including:
- Project overview and main purpose
- Architecture and technology stack
- Authentication and authorization details
- Detailed API endpoint descriptions
- Data models and relationships
- Error handling and security considerations

### [API Quick Reference](./API_QUICK_REFERENCE.md)
Quick reference guide for developers including:
- All API endpoints in table format
- Authentication requirements
- Common query parameters
- Response formats
- Brand configuration details

## 🚀 Quick Start

### Project Overview
The Backoffice Backend is a multi-tenant NestJS application designed to manage dating/matchmaking platform operations. It supports multiple brands with isolated data and provides comprehensive administrative tools.

### Key Features
- **Multi-tenant Architecture**: Supports 4 brands (100, 101, 102, 103)
- **Role-based Access Control**: Granular permissions system
- **Multi-language Support**: Content translation management
- **Real-time Monitoring**: Session tracking and activity monitoring
- **External Integrations**: AWS services, Twilio, BigQuery, OpenAI

### Technology Stack
- **Framework**: NestJS (Node.js)
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with refresh tokens
- **File Storage**: AWS S3
- **External Services**: Twilio, BigQuery, OpenAI, AWS services

## 🔐 Authentication

### Authentication Flow
1. **Login**: `POST /api/auth/` with email/password
2. **Token Management**: JWT access token (15min) + refresh token (7 days)
3. **Session Tracking**: Automatic session creation and monitoring

### Authorization Levels
- **AuthGuard**: Basic authentication
- **EntityGuard**: Entity-level access control
- **RolesGuard**: Role-based permissions

## 🏗️ Architecture

### Multi-Tenant Setup
- **Main Router**: Routes requests to brand instances
- **Brand Instances**: Separate ports for each brand
- **Data Isolation**: Brand-specific data filtering
- **Shared Infrastructure**: Common codebase

### Port Configuration
```
Main Router: process.env.PORT
Brand 100: process.env.PORT + 100
Brand 101: process.env.PORT + 101
Brand 102: process.env.PORT + 102
Brand 103: process.env.PORT + 103
```

## 📋 API Categories

### Core Management
- **Profile Management**: User profile lifecycle
- **Content Management**: Multi-language content
- **Screen Management**: Application screens/pages
- **Communication**: Email, SMS, notifications

### Administrative
- **Role Management**: User roles and permissions
- **Group Management**: User grouping system
- **Settings**: Application configuration
- **Customer Support**: Ticket and support management

### Business Intelligence
- **Dashboard**: Statistics and analytics
- **Reports**: Business reporting
- **AI Simulations**: AI-powered features
- **Batch Processing**: Automated operations

## 🔧 Development

### Environment Setup
```bash
# Install dependencies
pnpm install

# Development mode
pnpm run start:dev

# Production mode
pnpm run start:prod
```

### Environment Variables
- `PORT`: Base port for main router
- `JWT_SECRET_KEY`: JWT signing key
- `JWT_SECRET_REFRESH_KEY`: Refresh token signing key
- `ENV`: Environment (dev/prod)
- Database connection strings
- AWS credentials
- External service API keys
- **Cursor Cloud Agents** (optional; required for “Send to AI” on support tickets): `CURSOR_API_KEY` from the [Cursor Dashboard](https://cursor.com/settings); `CURSOR_META_REPO_URL` as the full GitHub URL of the platform meta-repo; optional `CURSOR_META_REPO_REF` (defaults to `master`) for the base branch passed to the [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints). When a ticket is assigned to an AI triage user (`aiTicketUserIds`), the backend starts at most one triage agent per ticket every five minutes to avoid duplicate runs from rapid reassignment or create-then-assign flows.

### Testing
```bash
# Unit tests
pnpm run test

# E2E tests
pnpm run test:e2e

# Test coverage
pnpm run test:cov
```

## 🔒 Security

### CORS Configuration
- Allowed origins: `*.a-dmin.ai`
- Localhost allowed for development
- Credentials enabled

### JWT Security
- Access tokens: 15 minutes
- Refresh tokens: 7 days
- Secure cookies in production
- HTTP-only cookies

### Data Protection
- Password hashing
- Sensitive data filtering
- Sensitive profile attributes are persisted as `["hidden"]` in `attributesValues`, while searchable HMAC tokens are maintained in dedicated `__searchTokens` keys and `_sensitiveSearchTokens` for backoffice free-text lookup
- Secure file upload validation
- SQL injection prevention

## 📊 Monitoring

### Logging
- Winston logging integration
- Request/response logging
- Error tracking and alerting
- Performance monitoring
- Session activity tracking

### Health Checks
- `GET /api/utils/health`: Service health check
- Automatic error logging
- Request correlation IDs

## 🤝 Contributing

### Code Style
- ESLint configuration
- Prettier formatting
- TypeScript strict mode
- NestJS best practices

### Testing
- Unit tests for services
- E2E tests for endpoints
- Integration tests for modules

## 📞 Support

For questions and support:
1. Check the detailed [API Documentation](./API_DOCUMENTATION.md)
2. Use the [Quick Reference](./API_QUICK_REFERENCE.md) for endpoint lookup
3. Review error logs and monitoring data
4. Contact the development team

## 📄 License

This project is proprietary and confidential. All rights reserved. 