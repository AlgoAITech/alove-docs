# Mujual Back Office - Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Main Purpose](#main-purpose)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Routes and Screens](#routes-and-screens)
6. [Common Components](#common-components)
7. [@alove Components Directory](#alove-components-directory)
8. [Key Features](#key-features)
9. [Development Guidelines](#development-guidelines)

## Project Overview

**Mujual Back Office** is a comprehensive React-based administrative dashboard built on top of the Otis Admin PRO template. It serves as a powerful back-office management system for a matchmaking/dating platform, providing administrators with tools to manage users, content, questionnaires, communications, and various business operations.

**Version:** 2.0.1  
**Framework:** React 18.1.0 with TypeScript  
**UI Library:** Material-UI (MUI) v7.1.1  
**State Management:** React Context API  
**Routing:** React Router DOM 6.3.0  

## Main Purpose

The Mujual Back Office serves as a comprehensive administrative interface for managing a matchmaking platform with the following core functionalities:

### Primary Functions:
- **User Management**: Manage end users, system users, roles, and permissions
- **Content Management**: Handle app content, translations, communications, and info screens
- **Questionnaire System**: Manage questionnaires, questions, attributes, and user responses
- **Matchmaking Operations**: Handle shidduch requests, SME profiles, and matchmaking workflows
- **Customer Support**: Ticket management system for both mobile app and admin panel
- **Reporting & Analytics**: Comprehensive reporting on users, questions, communications, and interactions
- **Brand Management**: Multi-brand support with brand-specific settings
- **AI & Automation**: AI simulations, batch triggers, and automated workflows

### Business Context:
The platform appears to be a sophisticated matchmaking service that uses questionnaires, AI algorithms, and human matchmakers (SMEs) to facilitate connections between users. The back office provides the administrative infrastructure to manage all aspects of this service.

## Technology Stack

### Core Technologies:
- **React 18.1.0** - Main framework
- **TypeScript** - Type safety and development experience
- **Material-UI (MUI) 7.1.1** - UI component library
- **React Router DOM 6.3.0** - Client-side routing
- **Formik 2.2.9** - Form management
- **Yup 0.32.11** - Form validation
- **Axios** - HTTP client for API calls

### Key Libraries:
- **@mui/x-data-grid-pro** - Advanced data grid with filtering, sorting, grouping
- **@mui/x-date-pickers** - Date and time pickers
- **@tiptap/react** - Rich text editor
- **React Dropzone** - File upload functionality
- **Chart.js & React Chart.js 2** - Data visualization
- **FullCalendar** - Calendar component
- **React Kanban** - Kanban board functionality

### Development Tools:
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Sass** - CSS preprocessing
- **pnpm** - Package manager

## Project Structure

```
src/
├── components/
│   ├── alove/           # Custom reusable components
│   ├── MD*/             # Material Design components
│   └── @/               # Additional components
├── layouts/             # Page layouts and screens
├── context/             # React context providers
├── models/              # TypeScript type definitions
├── utils/               # Utility functions
├── hooks/               # Custom React hooks
├── assets/              # Static assets
├── styles/              # Global styles
├── routes.tsx           # Application routing
├── App.tsx              # Main application component
└── index.js             # Application entry point
```

## Routes and Screens

The application uses a hierarchical routing structure with role-based access control. Routes are organized into main sections:

### 1. User Management Section
- **End Users** (`/endUsers`) - Manage platform users
- **View end user** (`/endUsers/:id`) - For brand managers: bottom actions **Link child account** (when `userType` is parent) or **Link a parent** otherwise; dialog collects the other account’s profile or user ID and calls `POST /api/profiles/:id/link-parent-child`, which updates `parent_user_id`, `familyId`, `isChild`, `userType`, and Cognito `custom:parent` on the child side.
- **System Users** (`/systemUsers`) - Admin user management
- **Roles & Permissions** (`/roles`) - Role-based access control
- **Groups** (`/groups`) - User grouping functionality
- **Introductions** (`/introductions`) - User interaction management

### 2. Content Management Section
- **App Content** (`/content`) - Application content management
- **Communications** (`/communications`) - Message and notification management. A plain-language guide for operators (how one-time, event-triggered, and delayed sends behave per channel) lives in the static docs site: `docs/Content/communications.html` in this repository.
- **Info Screens** (`/screens`) - Information display screens
- **Translations** (`/translations_list`) - Multi-language support
- **Positions** (`/settings/positions`) - Position management

### 3. Questionnaire System
- **Questionnaires** (`/questionnaires`) - Survey management
- **Questions List** (`/questions`) - Individual question management
- **Attributes** (`/attributes`) - User attribute definitions
- **Predictors** (`/predictors`) - Matching algorithm predictors

### 4. Matchmaking Operations
- **Shidduch Requests** (`/shidduch-requests`) - Matchmaking requests
- **SME Profiles** (`/smeProfiles`) - Matchmaker profiles
- **Shidduch Declines** (`/shidduch-declines`) - Declined matches

### 5. Support Center
- **Customer Support Tickets** (`/tickets/customerSupport`) - User support tickets
- **System Tickets** (`/tickets/system`) - Internal system tickets
- **Support Settings** (`/customerSupportSettings`) - Support configuration

### 6. Content Center
- **Content Types** (`/contentsCenter`) - Content categorization
- **Content Management** (`/contentsCenter/:type`) - Type-specific content

### 7. Reports & Analytics
- **Users Report** (`/reports/users`) - User analytics
- **Questions Report** (`/reports/questions`) - Question performance
- **Communications Report** (`/reports/communications`) - Communication metrics
- **Interactions Report** (`/reports/interactions`) - User interaction data
- **Customer Support Report** (`/reports/customerSupport`) - Support metrics
- **Dynamic reports visibility** - Inactive dynamic reports (`isActive = false`) are filtered out and are not shown in menu/navigation.

### 8. Settings & Configuration
- **Brand Settings** (`/brandSettings/:id`) - Brand-specific configurations
- **Admin Settings** (`/settings/*`) - System-wide settings
- **General Codes** (`/general-codes`) - System codes management
- **Agents** (`/agents`) - Centralized agent management UI (TablePage + ItemPageContainer) for editing agent description/prompt/model/tokens/temperature/apiKey
- **Agent Prompt Settings** (`/general-codes?type=agent`) - Centralized LLM prompt/model/tokens/apiKey configuration via `general_codes.extra` (apiKey is encrypted at rest and shown masked in UI/API)
- **Auto Update Profile Codes** (`/auto-update-profile-codes`) - Manage daily profile auto-update rules and manually trigger the daily lambda
- **Profile Images** (`/settings/profile-images`) - Image asset management

### 9. AI & Automation
- **AI Simulations** (`/AISimulations`) - AI model testing
- **Batch Triggers** (`/batchTriggers`) - Automated workflow triggers
- **Screen Flow Management** (`/screen_flow_mgmt`) - User flow configuration

## Common Components

### Core MUI Components (MD*)
The application extends Material-UI components with custom styling and functionality:

- **MDBox** - Flexible container component
- **MDButton** - Enhanced button with consistent styling
- **MDInput** - Form input component
- **MDTypography** - Typography component
- **MDAvatar** - User avatar component
- **MDBadge** - Notification badge component
- **MDSnackbar** - Toast notification component

### Layout Components
- **Sidenav** - Main navigation sidebar
- **Configurator** - Theme and layout configuration
- **Footer** - Application footer
- **Navbar** - Top navigation bar

## @alove Components Directory

The `@alove` directory contains custom, reusable components specifically designed for this back-office application. These components follow consistent design patterns and provide enhanced functionality beyond standard MUI components.

### Core Components

#### 1. **CardItem** (`CardItem.tsx`)
A collapsible card component used throughout the application for organizing content sections.

**Features:**
- Collapsible/expandable sections
- Optional add buttons
- Filter integration
- Responsive design (half-width support)
- Custom action buttons

**Usage:**
```tsx
<CardItem 
  title="Section Title"
  id="unique-id"
  defaultClosed={false}
  addButton="Add New Item"
  onAddNewContact={() => handleAdd()}
>
  {/* Content goes here */}
</CardItem>
```

#### 2. **TablePage** (`TablePage.tsx`)
A comprehensive data table component with advanced features for displaying and managing data.

**Features:**
- MUI DataGrid Pro integration
- Server-side filtering and sorting
- Custom filters and search
- Pagination support
- Row selection and actions
- Mobile-responsive design
- Statistics panel integration
- Export functionality

**Key Props:**
- `title` - Table title
- `table.columns` - Column definitions
- `table.loadNext` - Data loading function
- `filters` - Filter configurations
- `stats` - Statistics panel data
- `actions` - Action buttons

#### 3. **ActionsRow** (`ActionsRow.tsx`)
Manages action buttons and filters in a consistent layout.

**Features:**
- Role-based action visibility
- Feature-based action filtering
- Save and add action separation
- Filter integration
- Mobile-responsive design

#### 4. **AloveSwitch** (`AloveSwitch.tsx`)
Enhanced switch component with title and subtitle support.

**Features:**
- Title and subtitle display
- Disabled state support
- Consistent styling with MUI Grid

#### 5. **AloveTextFields** (`AloveTextFields.tsx`)
Rich text editor component with advanced formatting capabilities.

**Features:**
- TipTap editor integration
- Rich text formatting
- Color highlighting
- Link support
- Custom tag replacements
- Special syntax highlighting (%s, @mentions, ~tags)

#### 6. **ImageUploader** (`ImageUploader.tsx`)
Advanced image upload component with multiple upload methods.

**Features:**
- Drag and drop support
- Paste from clipboard
- Multiple image support
- Preview functionality
- Folder organization
- Upload progress tracking

#### 7. **AloveDialog** (`AloveDialog.tsx`)
Custom dialog component with consistent styling and behavior.

#### 8. **AloveAutocomplete** (`AloveAutocomplete.tsx`)
Enhanced autocomplete component with custom styling.

#### 9. **AloveChipsField** (`AloveChipsField.tsx`)
Chip-based input field for tags and categories.

#### 10. **AloveNumeric** (`AloveNumeric.tsx`)
Numeric input component with validation.

### Utility Components

#### 11. **Translator** (`Translator.tsx`)
Internationalization component for text translation.

#### 12. **Chips** (`Chips.tsx`)
Display component for status indicators and tags.

#### 13. **CopyableId** (`CopyableId.tsx`)
Copy-to-clipboard functionality for IDs and references.

#### 14. **RedCircleBadge** (`RedCircleBadge.tsx`)
Notification badge component.

#### 15. **VerticalDivider** (`VerticalDivider.tsx`)
Visual separator component.

### Mobile Components

#### 16. **MobileListItem** (`MobileListItem.tsx`)
Mobile-optimized list item component.

#### 17. **MobileDotMenu** (`MobileDotMenu.tsx`)
Mobile menu component with dot navigation.

### Specialized Components

#### 18. **StatsPanel** (`StatsPanel.tsx`)
Statistics display panel with key metrics.

#### 19. **EditableTable** (`EditableTable.tsx`)
Table component with inline editing capabilities.

#### 20. **DropDownButton** (`DropDownButton.tsx`)
Button component with dropdown menu integration.

#### 21. **EnumAutocomplete** (`EnumAutocomplete.tsx`)
Autocomplete component for enum values.

#### 22. **UserName** (`UserName.tsx`)
User name display component with avatar.

### Dialog Components

#### 23. **AddGroupDialog** (`AddGroupDialog.tsx`)
Dialog for creating new groups.

#### 24. **EditGeneralCodeDialog** (`EditGeneralCodeDialog.tsx`)
Dialog for editing general codes.

#### 25. **AddGeneralCodeDialog** (`AddGeneralCodeDialog.tsx`)
Dialog for adding new general codes.

#### 26. **UpdateGeneralCodeDialog** (`UpdateGeneralCodeDialog.tsx`)
Dialog for updating existing general codes.

#### 27. **CropImageDialog** (`CropImageDialog.tsx`)
Image cropping dialog with preview.

#### 28. **ImageDialog** (`ImageDialog.tsx`)
Image preview and management dialog.

### Content Components

#### 29. **EmbeddedLinkPreview** (`EmbeddedLinkPreview.tsx`)
Link preview component with metadata display.

#### 30. **OGTagsPreview** (`OGTagsPreview.tsx`)
Open Graph tags preview component.

#### 31. **UnmatchReasons** (`UnmatchReasons.tsx`)
Component for displaying unmatch reasons.

#### 32. **MMAvatar** (`MMAvatar.tsx`)
Matchmaker avatar component.

#### 33. **BrandLogo** (`BrandLogo.js`)
Brand logo display component.

#### 34. **OutlinedBox** (`OutlinedBox.js`)
Outlined container component.

#### 35. **ResumeIcon** (`ResumeIcon.js`)
Resume icon component.

## Key Features

### 1. Role-Based Access Control
- Granular permissions system
- Page-level access control
- Feature-based visibility
- **Roles are organized as a tree** (`bo_roles.parent_id`): each role inherits the union of every descendant's permissions at runtime, so permission editing happens only at the leaves and parents automatically gain everything below.
  - Roles list (`/roles`) renders the tree from `parent_id` (no role-type grouping) and admins can re-parent a role inline.
  - Role permissions screen marks cells that are already granted by a descendant as a disabled check with a tooltip naming those descendants.
  - System-user role pickers show only the current viewer's role and its descendants (sub-tree filter).
  - Two CLI commands maintain the tree per brand:
    - `pnpm run cli rearrange-roles-tree` — Super Admin → Brand Admin → managers (one per type) → roles of that type.
    - `pnpm run cli clean-redundant-role-permissions` — strip permissions from parents that any descendant already holds.
  - Legacy `bo_roles.type` and `bo_roles.is_manager` columns are deprecated and ignored by permission resolution.

### 2. Multi-Brand Support
- Brand-specific configurations
- Brand isolation
- Brand-specific content management
- Multi-tenant architecture

### 3. Advanced Data Management
- Server-side pagination
- Real-time filtering and sorting
- Bulk operations
- Data export capabilities
- Audit trails

### 4. Internationalization
- Multi-language support
- Dynamic translation system
- RTL language support
- Cultural adaptations

### 5. Mobile Responsiveness
- Mobile-first design approach
- Touch-friendly interfaces
- Responsive data grids
- Mobile-specific components

### 6. Real-time Features
- Live notifications
- Real-time updates
- WebSocket integration
- Activity tracking

### 7. Advanced Reporting
- Custom report generation
- Data visualization
- Export capabilities
- Scheduled reports

### 8. AI Integration
- AI simulation testing
- Automated workflows
- Predictive analytics
- Machine learning integration

### 9. Feature-Gated Match Advisor Insights
- The introduction details screen supports a feature flag for Match Advisor insights.
- Feature key: `matchAdvisorInsights` (under `app_features` / `bo` settings, consumed via `useSettings().hasFeature(...)`).
- When disabled for a brand, the **Match Advisor** section and its side-nav anchor are hidden in Backoffice.
- The introductions list (`/introductions`) includes an **Advisor score** column sourced from `llmMatchAdvisor.score` for quick triage without opening each introduction.

## Development Guidelines

### Component Development
1. **Use @alove components** for consistency
2. **Follow MUI design patterns** for styling
3. **Implement responsive design** for all components
4. **Use TypeScript** for type safety
5. **Follow the established naming conventions**

### State Management
1. **Use React Context** for global state
2. **Implement proper error boundaries**
3. **Handle loading states** consistently
4. **Use optimistic updates** where appropriate

### API Integration
1. **Use centralized API utilities**
2. **Implement proper error handling**
3. **Use consistent data transformation**
4. **Handle authentication properly**

### Performance Optimization
1. **Implement proper memoization**
2. **Use lazy loading** for routes
3. **Optimize bundle size**
4. **Implement proper caching strategies**

### Security
1. **Validate all inputs**
2. **Implement proper authentication**
3. **Use role-based access control**
4. **Sanitize user-generated content**

### Testing
1. **Write unit tests** for components
2. **Implement integration tests**
3. **Use proper mocking strategies**
4. **Test error scenarios**

### AWS Amplify (web app) and source maps

The deployable React app is built on **AWS Amplify** (`backoffice_client/amplify.yml`, `app/` root). Production builds upload source maps to **Coralogix** and archive **`build/static/js/*.js` plus `*.map`** to `s3://<assets-bucket>/private/source-maps/backoffice-client/<AWS_JOB_ID>/` for decoding minified browser stacks. Bucket selection follows branch defaults in Amplify or the **`SOURCE_MAPS_S3_BUCKET`** env override.

This documentation provides a comprehensive overview of the Mujual Back Office project, its architecture, components, and development guidelines. The system is designed to be scalable, maintainable, and user-friendly while providing powerful administrative capabilities for the matchmaking platform. 