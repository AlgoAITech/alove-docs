# Mujual App - Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Purpose and Mission](#purpose-and-mission)
3. [Architecture Overview](#architecture-overview)
4. [Technology Stack](#technology-stack)
5. [Project Structure](#project-structure)
6. [Module Documentation](#module-documentation)
7. [Infrastructure](#infrastructure)
8. [Development Workflow](#development-workflow)
9. [Deployment](#deployment)
10. [Testing Strategy](#testing-strategy)

## Project Overview

**Mujual App** is a sophisticated multi-module Flutter application designed as a modern dating and matchmaking platform. The application supports multiple brands and configurations through a flavor-based architecture, allowing the same codebase to serve different dating app brands like "Mujual", "Alove", and "Zuug".

### Key Features
- **Multi-brand Support**: Single codebase supporting multiple dating app brands
- **Advanced Matchmaking**: AI-powered introduction and matching system
- **Real-time Communication**: Chat, audio, and video calling capabilities
- **Profile Management**: Comprehensive user profile and preference settings
- **Questionnaire System**: Dynamic onboarding and compatibility assessment
- **Payment Integration**: Premium features and subscription management
- **Multi-platform**: iOS, Android, and Web support

## Purpose and Mission

The Mujual App serves as a comprehensive dating and relationship platform with the following core purposes:

### Primary Objectives
1. **Facilitate Meaningful Connections**: Help users find compatible partners through intelligent matchmaking algorithms
2. **Provide Safe Communication**: Offer secure chat, audio, and video calling features for user interactions
3. **Support Relationship Development**: Guide users through relationship stages from introduction to engagement
4. **Ensure User Privacy**: Implement robust privacy controls and data protection measures
5. **Enable Scalable Operations**: Support multiple brands and configurations from a single codebase

### Target Users
- **Primary**: Adults seeking serious relationships and meaningful connections
- **Secondary**: Users interested in matchmaking services and relationship guidance
- **Tertiary**: Premium users seeking enhanced features and extended capabilities

## Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   UI Modules │ │ Navigation  │ │   Themes    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    Core     │ │   Models    │ │ Repositories│          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Remote    │ │    Local    │ │   Storage   │          │
│  │   APIs      │ │   Cache     │ │   Services  │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   AWS       │ │  Firebase   │ │   Analytics │          │
│  │  Services   │ │  Services   │ │   & Logging │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Principles
- **Modular Design**: Clear separation of concerns with independent modules
- **Dependency Injection**: Using GetIt for service locator pattern
- **Reactive Programming**: GetX for state management and reactive UI
- **Multi-platform Support**: Shared codebase for mobile and web
- **Flavor-based Configuration**: Environment-specific builds and configurations

## Technology Stack

### Frontend Framework
- **Flutter**: Cross-platform UI framework (v3.29.3+)
- **Dart**: Programming language (v3.7.2+)

### State Management & Navigation
- **GetX**: State management, dependency injection, and routing
- **GetIt**: Service locator for dependency injection
- **Go Router**: Declarative routing for web and mobile

### Backend & Cloud Services
- **AWS Amplify**: Authentication, storage, and backend services
- **AWS Cognito**: User authentication and authorization
- **AWS S3**: File storage and media management
- **Firebase**: Push notifications, analytics, and crash reporting
- **Firebase Cloud Messaging**: Real-time notifications

### Communication & Real-time Features
- **WebSocket**: Real-time chat and messaging
- **Agora.io**: Video and audio calling capabilities

### Data Management
- **Hive**: Local data storage and caching
- **JSON**: Data serialization and API communication
- **Shared Preferences**: Local settings and preferences

### Development Tools
- **RPS**: Script runner for development workflows
- **Melos**: Monorepo management
- **Flutter Flavorizr**: Build flavor management
- **Codemagic**: CI/CD for mobile builds
- **AWS Amplify**: Web deployment and hosting

### Monitoring & Analytics
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Error reporting and monitoring
- **Coralogix**: Log aggregation and monitoring
- **Talker**: Logging and debugging framework

## Project Structure

```
meeplus_app/
├── lib/                          # Main application code
│   ├── main.dart                 # Application entry point
│   ├── mujual_app.dart           # Main app widget
│   ├── di/                       # Dependency injection
│   ├── navigation/               # Navigation configuration
│   ├── pages/                    # Main app pages
│   └── ui/                       # Shared UI components
├── modules/                      # Modular architecture
│   ├── core/                     # Core business logic
│   ├── models/                   # Data models
│   ├── common_dependencies/      # Shared dependencies
│   ├── ui/                       # UI modules
│   ├── mock_server/              # Mock server for testing
│   ├── environment/              # Environment configurations
│   └── talker_flutter/           # Logging framework
├── assets/                       # Static assets
│   ├── images/                   # Images and icons
│   ├── animations/               # Lottie animations
│   ├── fonts/                    # Custom fonts
│   ├── translations/             # Localization files
│   └── jsons/                    # Configuration files
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── web/                          # Web-specific code
├── linux/                        # Linux-specific code
├── test/                         # Unit tests
├── integration_test/             # Integration tests
└── scripts/                      # Build and deployment scripts
│   └── create_flavor.sh         # Dynamic flavor creation script
```

## Module Documentation

### Core Module (`modules/core/`)
The core module contains the fundamental business logic and services that power the entire application.

#### Key Components:
- **Authentication**: User login, registration, and session management
- **Profile Management**: User profile CRUD operations and preferences
- **Chat System**: Real-time messaging and conversation management
- **Introductions**: Matchmaking and introduction management
- **Notifications**: Push notifications and local notification handling
- **Analytics**: User behavior tracking and event logging
- **Storage**: File upload, download, and media management
- **Network**: HTTP client configuration and API communication
- **Translations**: Multi-language support and localization
- **Payments**: Subscription and premium feature management

#### Dependencies:
- AWS Amplify for authentication and storage
- Firebase for notifications and analytics
- WebSocket for real-time communication
- Hive for local data persistence

### Models Module (`modules/models/`)
Contains all data models and domain entities used throughout the application.

#### Key Models:
- **User**: User profile and authentication data
- **Introduction**: Matchmaking and relationship data
- **Conversation**: Chat and messaging data
- **Profile**: User profile and preference data
- **Questionnaire**: Dynamic form and survey data
- **Payment**: Subscription and billing data

### UI Modules (`modules/ui/`)
Modular UI components organized by feature and functionality.

#### Available UI Modules:
- **ui_common**: Shared UI components and utilities
- **ui_login**: Authentication and login screens
- **ui_introductions**: Matchmaking and introduction screens
- **ui_lora_chat**: AI-powered chat interface
- **ui_questionnaires**: Dynamic form and survey screens
- **ui_profile_settings**: Profile management screens
- **ui_me**: User profile and personal information screens
- **ui_settings**: Application settings and configuration
- **ui_payments**: Subscription and billing screens
- **ui_matchmaker_page**: Matchmaker service screens
- **ui_public_profile**: Public profile viewing screens
- **ui_dynamic_screens**: Dynamic content rendering
- **ui_contact_us**: Support and contact screens
- **ui_content_center**: Content management screens

### Common Dependencies (`modules/common_dependencies/`)
Shared utilities, constants, and dependencies used across modules.

#### Key Utilities:
- **Platform Utils**: Platform-specific functionality
- **Server Settings**: Feature flags and configuration
- **Validation**: Input validation and data sanitization
- **Date Utils**: Date and time manipulation
- **Network Utils**: Network connectivity and status

### Mock Server (`modules/mock_server/`)
Development and testing server for simulating backend services.

#### Features:
- **API Simulation**: Mock endpoints for development
- **Data Generation**: Fake data for testing
- **Response Simulation**: Simulated API responses
- **Error Testing**: Error scenario simulation

## Infrastructure

### Cloud Infrastructure

#### AWS Services
- **AWS Amplify**: Backend-as-a-Service for authentication, storage, and hosting
- **AWS Cognito**: User authentication and authorization
- **AWS S3**: File storage for images, videos, and documents
- **AWS Lambda**: Serverless functions for business logic
- **AWS CloudFront**: Content delivery network
- **AWS Route 53**: DNS management and routing

#### Firebase Services
- **Firebase Cloud Messaging**: Push notifications
- **Firebase Analytics**: User behavior analytics
- **Firebase Crashlytics**: Error reporting and monitoring
- **Firebase App Check**: App integrity verification

#### Third-Party Services
- **Agora.io**: Real-time video and audio calling
- **Coralogix**: Log aggregation and monitoring
- **Stripe**: Payment processing (implied by payment features)

### Development Infrastructure

#### CI/CD Pipeline
- **GitHub Actions**: Mobile app build and deployment (Android)
- **Codemagic**: Mobile app build and deployment (iOS)
- **AWS Amplify**: Web app build and deployment
- **GitHub Actions**: Automated testing and quality checks

#### Monitoring and Logging
- **Firebase Crashlytics**: Error tracking and crash reporting
- **Coralogix**: Centralized logging and monitoring
- **Talker**: In-app logging and debugging
- **Firebase Analytics**: User engagement metrics

## Development Workflow

### Environment Setup
1. **Flutter SDK**: Install Flutter 3.29.3 or higher
2. **Dart SDK**: Install Dart 3.7.2 or higher
3. **RPS Tool**: Install for script execution
   ```bash
   dart pub global activate rps --version 0.7.0
   ```
4. **Dependencies**: Install all module dependencies
   ```bash
   flm-get  # Custom script for multi-module dependency installation
   ```

### Flavor Configuration
The application supports multiple flavors for different environments and brands. Flavors are created dynamically at CI runtime using the `create_flavor` script, rather than being stored in the git repository.

#### Available Flavors:
- **dev**: Development environment
- **staging**: Staging environment
- **prod**: Production environment
- **alovedev**: Alove brand development
- **zuugdev**: Zuug brand development
- **zuugstaging**: Zuug brand staging
- **zuugprod**: Zuug brand production

#### Flavor Creation Process:
During CI/CD execution, the `create_flavor` script dynamically generates flavor-specific assets and configurations:
- Brand-specific assets and configurations
- Environment-specific API endpoints
- Platform-specific build settings
- Dynamic asset fetching from S3

#### Running Different Flavors:
```bash
# Development
rps dev

# Staging
rps staging

# Production
rps prod

# Brand-specific
rps zuugdev
rps zuugstaging
rps zuugprod
```

### Module Development
1. **Create New Module**:
   ```bash
   dart create -t package modules/MODULE_NAME
   ```
2. **Add to pubspec.yaml**:
   ```yaml
   publish_to: 'none'
   ```
3. **Register in Main App**: Add module dependency to main pubspec.yaml
4. **Implement Features**: Develop module-specific functionality
5. **Test Integration**: Ensure proper integration with other modules

### Code Quality
- **Flutter Lints**: Code style and best practices
- **Analysis Options**: Custom linting rules
- **Integration Tests**: End-to-end testing
- **Unit Tests**: Module-specific testing

## Deployment

### Mobile Deployment

#### iOS Deployment
- **Build Process**: Automated via Codemagic
- **App Store**: Automated upload to App Store Connect
- **Code Signing**: Automated certificate management
- **Version Management**: Automated version incrementing

#### Android Deployment
- **Build Process**: Automated via GitHub Actions
- **Play Store**: Automated upload to Google Play Console
- **APK/Bundle**: Multiple build formats supported
- **Release Management**: Automated release notes

### Web Deployment
- **Build Process**: Automated via AWS Amplify
- **Hosting**: AWS Amplify hosting
- **CDN**: CloudFront for global distribution
- **SSL**: Automated SSL certificate management
- **CI Env Injection**: Web runtime `.env` payload is passed to Flutter with `--dart-define=ENV_BASE64=...` and read using `String.fromEnvironment` in `lib/di/service_locator.dart` (avoids mutating Dart source during Amplify builds)
- **Source maps in S3**: Each Amplify web build uploads maps (and `main.dart.js`) under `s3://<assets-bucket>/private/source-maps/meeplus-web/<AWS_JOB_ID>/` for internal decoding of minified stacks (Coralogix RUM, support). Same bucket family as flavor assets (`mujual-prod-assets`, `mujual-staging-assets`, `alove-dev-assets` per branch).

### Environment Management
- **Configuration**: Environment-specific settings
- **Feature Flags**: Dynamic feature toggling
- **Asset Management**: Brand-specific assets (created dynamically at CI runtime)
- **API Endpoints**: Environment-specific APIs
- **Flavor Creation**: Dynamic flavor generation using `create_flavor` script

## Testing Strategy

### Testing Pyramid
```
┌─────────────────────────────────────┐
│           E2E Tests                 │
│      (Integration Tests)            │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│         Widget Tests                │
│      (Component Tests)              │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│         Unit Tests                  │
│      (Module Tests)                 │
└─────────────────────────────────────┘
```

### Test Types

#### Unit Tests
- **Location**: `test/` directory in each module
- **Coverage**: Business logic and utility functions
- **Framework**: Flutter Test
- **Execution**: `flutter test`

#### Integration Tests
- **Location**: `integration_test/` directory
- **Coverage**: End-to-end user workflows
- **Framework**: Integration Test
- **Execution**: `flutter test integration_test/`

#### Widget Tests
- **Location**: `test/` directory in UI modules
- **Coverage**: UI component behavior
- **Framework**: Flutter Test
- **Execution**: `flutter test`

### Test Automation
- **CI/CD Integration**: Automated testing in build pipeline
- **Coverage Reporting**: Code coverage metrics
- **Quality Gates**: Minimum coverage requirements
- **Performance Testing**: App performance benchmarks

## Conclusion

The Mujual App represents a sophisticated, enterprise-grade dating application built with modern Flutter architecture. Its modular design, multi-brand support, and comprehensive feature set make it a powerful platform for facilitating meaningful relationships. The project demonstrates best practices in mobile development, including clean architecture, comprehensive testing, and robust deployment strategies.

The application's success is built on its ability to:
- Scale across multiple brands and markets
- Provide secure and engaging user experiences
- Maintain high code quality and reliability
- Support rapid feature development and deployment
- Ensure data privacy and user security

This documentation serves as a comprehensive guide for understanding, developing, and maintaining the Mujual App platform. 