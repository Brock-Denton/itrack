# iTrack Database Documentation

## Overview
This document provides a comprehensive overview of the iTrack database schema, including all tables, fields, relationships, and their usage throughout the application.

## Database Tables

### 1. users
**Purpose**: Stores user account information and authentication data.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key, unique identifier | Used throughout app for user identification |
| username | VARCHAR(50) | Unique username for login | LoginView, ProfileView, user identification |
| email | VARCHAR(255) | Optional email address | Google Sign-In, user profile display |
| google_id | VARCHAR(255) | Google OAuth identifier | Google Sign-In authentication |
| created_at | TIMESTAMP | Account creation timestamp | ProfileView "Member since" display |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |

**Relationships**:
- One-to-many with categories, time_entries, notes, daily_goals
- One-to-one with user_profiles

**Usage in Views**:
- `LoginView`: Username input and validation
- `ProfileView`: User information display
- `AuthenticationManager`: User authentication and session management

---

### 2. user_profiles
**Purpose**: Stores additional user profile information and preferences.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key | Internal reference |
| user_id | UUID | Foreign key to users | Links to user account |
| profile_image | TEXT | Base64 encoded image or URL | ProfileView avatar display |
| profile_image_type | VARCHAR(20) | Type of profile image | Determines display method |
| created_at | TIMESTAMP | Profile creation timestamp | Internal tracking |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |

**Relationships**:
- Many-to-one with users

**Usage in Views**:
- `ProfileView`: Profile image display and management

---

### 3. categories
**Purpose**: Stores time tracking categories and their hierarchical structure.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key | Used throughout app for category identification |
| user_id | UUID | Foreign key to users | Links category to user |
| name | VARCHAR(100) | Category display name | CategoryDialView, SummaryView, all category displays |
| color | VARCHAR(7) | Hex color code | CategoryDialView, SummaryView, visual identification |
| icon | VARCHAR(50) | SF Symbol name | CategoryDialView, visual representation |
| parent_id | UUID | Foreign key to categories | Creates hierarchy, subcategory navigation |
| is_active | BOOLEAN | Soft delete flag | Filters active categories |
| created_at | TIMESTAMP | Category creation timestamp | Internal tracking |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |

**Relationships**:
- Many-to-one with users
- Self-referencing for parent-child relationships
- One-to-many with time_entries

**Usage in Views**:
- `HomeView`: Main category dial display
- `CategoryDialView`: Visual category representation
- `CategoryDetailView`: Subcategory navigation
- `SummaryView`: Category breakdown and analytics
- `AddCategoryView`: Category creation and editing

**Default Categories**:
- Work (blue, briefcase icon)
- Personal (red, person icon)
- Learning (green, graduation cap icon)

---

### 4. time_entries
**Purpose**: Stores individual time tracking sessions and their duration.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key | Internal reference |
| user_id | UUID | Foreign key to users | Links entry to user |
| category_id | UUID | Foreign key to categories | Links entry to category |
| start_time | TIMESTAMP | When tracking started | TimerView, duration calculations |
| end_time | TIMESTAMP | When tracking ended | Duration calculations, session completion |
| duration | INTERVAL | Total time tracked | SummaryView, analytics, progress bars |
| is_active | BOOLEAN | Currently tracking flag | TimerView, active session management |
| created_at | TIMESTAMP | Entry creation timestamp | Internal tracking |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |

**Relationships**:
- Many-to-one with users
- Many-to-one with categories

**Usage in Views**:
- `HomeView`: Current timer display
- `TimerView`: Active session management
- `SummaryView`: Time analytics and breakdowns
- `DataManager`: Timer persistence and background tracking

**Key Features**:
- Persistent timer that continues in background
- Real-time duration updates
- Session start/stop management

---

### 5. notes
**Purpose**: Stores general notes and task items.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key | Internal reference |
| user_id | UUID | Foreign key to users | Links note to user |
| content | TEXT | Note text content | NotesView display and editing |
| is_completed | BOOLEAN | Completion status | NotesView completion tracking |
| order | INTEGER | Display order | NotesView drag-and-drop reordering |
| created_at | TIMESTAMP | Note creation timestamp | Internal tracking |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |
| completed_at | TIMESTAMP | Completion timestamp | NotesView completion history |

**Relationships**:
- Many-to-one with users

**Usage in Views**:
- `NotesView`: Note display, editing, and completion
- `AddGoalView`: Note creation

---

### 6. daily_goals
**Purpose**: Stores daily goal items with date-specific tracking.

| Field | Type | Description | Usage in App |
|-------|------|-------------|--------------|
| id | UUID | Primary key | Internal reference |
| user_id | UUID | Foreign key to users | Links goal to user |
| content | TEXT | Goal text content | NotesView display and editing |
| is_completed | BOOLEAN | Completion status | NotesView completion tracking |
| order | INTEGER | Display order | NotesView drag-and-drop reordering |
| date | DATE | Goal date | NotesView date filtering and organization |
| created_at | TIMESTAMP | Goal creation timestamp | Internal tracking |
| updated_at | TIMESTAMP | Last update timestamp | Internal tracking |
| completed_at | TIMESTAMP | Completion timestamp | NotesView completion history |

**Relationships**:
- Many-to-one with users

**Usage in Views**:
- `NotesView`: Daily goal display and management
- `ActiveGoalsSection`: Today's goals display
- `CompletedGoalsSection`: Completed goals history
- `GoalRowView`: Individual goal management

**Key Features**:
- Date-specific goal tracking
- Automatic expiration after 24 hours
- Completion history and statistics

---

## Database Functions

### 1. get_time_summary()
**Purpose**: Calculates time summary for a user within a date range.

**Parameters**:
- `p_user_id`: User ID to filter by
- `p_start_date`: Start date for the range
- `p_end_date`: End date for the range

**Returns**: Table with category breakdown including:
- Category ID, name, and color
- Total duration per category
- Percentage of total time
- Entry count per category

**Usage**: `SummaryView` time analytics and breakdowns

### 2. get_subcategories()
**Purpose**: Retrieves all subcategories for a parent category.

**Parameters**:
- `p_parent_id`: Parent category ID

**Returns**: All active subcategories for the parent

**Usage**: `CategoryDetailView` subcategory navigation

---

## Data Flow and Relationships

### User Authentication Flow
1. User enters username or signs in with Google
2. `AuthenticationManager` checks/creates user record
3. User session established with user ID
4. `DataManager` loads user-specific data

### Time Tracking Flow
1. User selects category from `CategoryDialView`
2. `CategoryDetailView` shows subcategories or timer
3. User starts timer in `TimerView`
4. `DataManager` creates `time_entry` record
5. Timer persists in background
6. User stops timer, duration calculated and stored
7. `SummaryView` displays analytics

### Category Management Flow
1. User creates category in `AddCategoryView`
2. Category stored with user ID and hierarchy
3. `CategoryDialView` displays categories
4. User can edit, delete, or create subcategories
5. Changes reflected across all views

### Daily Goals Flow
1. User creates goal in `AddGoalView`
2. Goal stored with current date
3. `NotesView` displays today's goals
4. User completes goals, timestamps recorded
5. Completed goals move to history section

---

## Security and Access Control

### Row Level Security (RLS)
All tables have RLS enabled with policies ensuring:
- Users can only access their own data
- No cross-user data leakage
- Secure authentication and authorization

### Data Validation
- Username uniqueness enforced
- Email uniqueness for Google Sign-In
- Category hierarchy validation
- Time entry duration calculations
- Date range validations

---

## Performance Optimizations

### Indexes
- User lookup indexes (username, email, google_id)
- Category hierarchy indexes (user_id, parent_id)
- Time entry indexes (user_id, category_id, start_time)
- Date-based indexes for daily goals and time entries

### Query Optimization
- Efficient time summary calculations
- Optimized category hierarchy queries
- Date range filtering for analytics
- Soft delete patterns for categories

---

## Future Enhancements

### Potential Schema Changes
1. **Time Periods Table**: For custom time period definitions
2. **Category Templates**: For sharing category structures
3. **Time Entry Tags**: For additional categorization
4. **User Preferences**: For app customization
5. **Data Export**: For backup and migration

### Analytics Enhancements
1. **Weekly/Monthly Reports**: Extended time period analysis
2. **Productivity Metrics**: Goal completion rates
3. **Time Pattern Analysis**: Usage trends and insights
4. **Category Performance**: Time allocation optimization

---

## Maintenance and Monitoring

### Regular Tasks
1. **Data Cleanup**: Remove old completed goals
2. **Index Maintenance**: Monitor query performance
3. **Backup Verification**: Ensure data integrity
4. **Security Audits**: Review access patterns

### Monitoring Points
1. **User Growth**: Track new user registrations
2. **Data Volume**: Monitor table sizes and growth
3. **Query Performance**: Identify slow queries
4. **Error Rates**: Track failed operations

This documentation serves as a comprehensive reference for understanding the iTrack database structure and its integration with the SwiftUI application. It should be updated as the schema evolves and new features are added.
