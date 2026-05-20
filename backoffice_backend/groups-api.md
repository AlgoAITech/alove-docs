# Groups API Documentation

## Overview
The Groups API provides functionality to manage groups and their relationships with profiles. Groups can contain multiple profiles, and profiles can belong to multiple groups.

### Groups Table (selected columns)
- `attached_attribute_rules` (JSONB, nullable): array of `{ "attributeName": string, "values": string[] }`. When a profile is **first** attached to the group (mobile flow via `attachGroupById` or backoffice POST add-to-group), each listed attribute is set on `profiles.attributes_values` to the given value list. **Sensitive attributes must not appear in these rules**; create/update group and attach flows return an error if any rule targets a sensitive attribute. Changes are audited in `profile_attribute_change_log` with `reason = attachedToGroup` and `group_id` referencing the group.

### Profile attribute change log
- `group_id` (int, nullable): populated together with `reason = attachedToGroup` when attributes are applied from `groups.attached_attribute_rules` on group attach.

## Database Schema

### Groups Table
```sql
CREATE TABLE public."groups" (
    id int8 GENERATED ALWAYS AS IDENTITY NOT NULL,
    "name" varchar NOT NULL,
    description varchar NULL,
    "type" int2 DEFAULT 0 NOT NULL,
    status_id int2 DEFAULT 1 NOT NULL,
    created timestamp DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT groups_pk PRIMARY KEY (id)
);
```

### Profiles Groups Junction Table
```sql
CREATE TABLE public.profiles_groups (
    profile_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created varchar DEFAULT timezone('utc'::text, now()) NOT NULL
);
CREATE UNIQUE INDEX profiles_groups_profile_id_idx ON public.profiles_groups USING btree (profile_id, group_id);
```

## API Endpoints

### Group Management

#### Create Group
- **POST** `/groups`
- **Body**: `CreateGroupDto`
- **Permissions**: ViewEndUser + Edit
- **Description**: Creates a new group

#### Get All Groups
- **GET** `/groups`
- **Permissions**: ViewEndUser
- **Description**: Retrieves all groups with their associated profiles

#### Get Group by ID
- **GET** `/groups/:id`
- **Permissions**: ViewEndUser
- **Description**: Retrieves a specific group with its associated profiles

#### Update Group
- **PUT** `/groups/:id`
- **Body**: `UpdateGroupDto`
- **Permissions**: ViewEndUser + Edit
- **Description**: Updates an existing group

#### Delete Group
- **DELETE** `/groups/:id`
- **Permissions**: ViewEndUser + Edit
- **Description**: Deletes a group

### Profile-Group Relationships

#### Get Profiles in Group
- **GET** `/groups/:id/profiles`
- **Permissions**: ViewEndUser
- **Description**: Retrieves all profiles associated with a specific group

#### Add Profile to Group
- **POST** `/groups/:id/profiles/:profileId`
- **Permissions**: ViewEndUser + Edit
- **Description**: Adds a profile to a group. If the group has `attached_attribute_rules`, those attributes are applied on this first attach and audited in `profile_attribute_change_log` (`reason = attachedToGroup`, `group_id` set).

#### Remove Profile from Group
- **DELETE** `/groups/:id/profiles/:profileId`
- **Permissions**: ViewEndUser + Edit
- **Description**: Removes a profile from a group

#### Get Groups for Profile
- **GET** `/profiles/:id/groups`
- **Permissions**: ViewEndUser
- **Description**: Retrieves all groups associated with a specific profile

## Data Transfer Objects (DTOs)

### CreateGroupDto
```typescript
{
  name: string;           // Required
  description?: string;   // Optional
  type?: number;         // Optional, defaults to 0
  statusId?: number;     // Optional, defaults to 1
}
```

### UpdateGroupDto
```typescript
{
  name?: string;          // Optional
  description?: string;   // Optional
  type?: number;         // Optional
  statusId?: number;     // Optional
}
```

## Entity Relationships

### Group Entity
- **Primary Key**: `id` (auto-generated identity)
- **Relationships**: Many-to-Many with Profile entity
- **Properties**:
  - `name`: Group name (required)
  - `description`: Group description (optional)
  - `type`: Group type (defaults to 0)
  - `statusId`: Group status (defaults to 1)
  - `created`: Creation timestamp
  - `profiles`: Array of associated profiles

### Profile Entity Updates
- Added `groups` property for Many-to-Many relationship with Group entity

## Usage Examples

### Creating a Group
```bash
curl -X POST /groups \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Premium Users",
    "description": "Users with premium subscription",
    "type": 1,
    "statusId": 1
  }'
```

### Adding a Profile to a Group
```bash
curl -X POST /groups/1/profiles/123e4567-e89b-12d3-a456-426614174000
```

### Getting Groups for a Profile
```bash
curl -X GET /profiles/123e4567-e89b-12d3-a456-426614174000/groups
```

## Error Handling

The API includes proper error handling for:
- Group or Profile not found
- Duplicate profile-group associations
- Invalid permissions
- Validation errors for required fields

## Security

All endpoints are protected with:
- EntityGuard for model validation
- RolesGuard for permission-based access control
- Access decorators for specific permission requirements 