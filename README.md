# iTrack - Time Tracking & Goal Management App

A professional, business-ready SwiftUI iPhone app for persistent time tracking and goal completion habit formation, ready for the App Store.

## Features

### 🏠 Homepage with Category Dial
- Interactive circular dial interface for category selection
- Default categories: Work, Personal, Learning
- Customizable colors, icons, and names
- Hierarchical subcategory support
- Persistent timer that continues in background

### ⏱️ Persistent Timer System
- Real-time timer that counts every second
- Continues tracking when app is backgrounded or closed
- Play/pause functionality with data persistence
- Visual timer display with category information
- Automatic duration calculation and storage

### 📊 Summary & Analytics
- Time breakdown by category with visual progress bars
- Multiple time period views: Hour, Day, Week, Month, Year
- Category percentage calculations
- Interactive legend with color coding
- Drill-down navigation to subcategories

### 📝 Daily Goals & Notes
- Bullet-point style goal tracking
- Checkbox completion system
- Drag-and-drop reordering
- 24-hour goal expiration
- Completed goals history
- Text editing and management

### 👤 User Authentication
- Simple username-based login
- Google Sign-In integration
- Persistent user sessions
- User profile management

## Technical Architecture

### Frontend (SwiftUI)
- **iOS 17+** compatibility
- **SwiftUI** for modern, declarative UI
- **MVVM** architecture pattern
- **Combine** for reactive programming
- **Core Data** for local persistence

### Backend (Supabase)
- **PostgreSQL** database
- **Row Level Security** for data protection
- **Real-time subscriptions** for live updates
- **Authentication** with Google OAuth
- **RESTful API** for data operations

### Key Components

#### Models
- `User`: User account and authentication data
- `Category`: Time tracking categories with hierarchy
- `TimeEntry`: Individual tracking sessions
- `Note`: General notes and tasks
- `DailyGoal`: Date-specific goal tracking

#### Managers
- `AuthenticationManager`: User authentication and sessions
- `DataManager`: Data persistence and Supabase integration
- `TimerManager`: Persistent timer functionality

#### Views
- `LoginView`: User authentication interface
- `HomeView`: Main category dial and timer display
- `SummaryView`: Time analytics and breakdowns
- `NotesView`: Daily goals and task management
- `ProfileView`: User settings and statistics

## Database Schema

### Core Tables
1. **users**: User accounts and authentication
2. **categories**: Time tracking categories
3. **time_entries**: Individual tracking sessions
4. **notes**: General notes and tasks
5. **daily_goals**: Date-specific goals

### Key Features
- **Hierarchical categories** with parent-child relationships
- **Soft delete** patterns for data preservation
- **Audit trails** with created/updated timestamps
- **Performance indexes** for optimal query speed
- **Row Level Security** for data protection

## Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ deployment target
- Supabase account
- Google Sign-In configuration

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd itrack
   ```

2. **Install dependencies**
   - Open `iTrack.xcodeproj` in Xcode
   - Dependencies will be automatically resolved via Swift Package Manager

3. **Configure Supabase**
   - Create a new Supabase project
   - Run the SQL schema from `supabase_schema.sql`
   - Update `AuthenticationManager.swift` and `DataManager.swift` with your Supabase URL and keys

4. **Configure Google Sign-In**
   - Add `GoogleService-Info.plist` to the project
   - Configure Google Sign-In in your Google Cloud Console
   - Update the client ID in the app configuration

5. **Build and run**
   - Select your target device
   - Build and run the project

## Configuration

### Supabase Setup
1. Create a new Supabase project
2. Run the provided SQL schema
3. Enable Row Level Security
4. Configure authentication providers
5. Update API keys in the app

### Google Sign-In Setup
1. Create a Google Cloud project
2. Enable Google Sign-In API
3. Configure OAuth consent screen
4. Create iOS OAuth client
5. Download `GoogleService-Info.plist`

## App Store Readiness

### Compliance
- ✅ **Privacy Policy** ready
- ✅ **Terms of Service** ready
- ✅ **Data Protection** (GDPR/CCPA compliant)
- ✅ **Accessibility** support
- ✅ **Localization** ready

### Performance
- ✅ **Optimized** for iPhone 17
- ✅ **Background** timer persistence
- ✅ **Efficient** data synchronization
- ✅ **Minimal** battery usage
- ✅ **Fast** app launch times

### User Experience
- ✅ **Intuitive** navigation
- ✅ **Professional** design
- ✅ **Smooth** animations
- ✅ **Responsive** interface
- ✅ **Error** handling

## Development Roadmap

### Phase 1 (Current)
- [x] Core time tracking functionality
- [x] Category management system
- [x] Daily goals and notes
- [x] User authentication
- [x] Supabase integration

### Phase 2 (Future)
- [ ] Advanced analytics and reports
- [ ] Category templates and sharing
- [ ] Time entry tags and filters
- [ ] Data export and backup
- [ ] Widget support

### Phase 3 (Future)
- [ ] Apple Watch companion app
- [ ] Team collaboration features
- [ ] Advanced goal tracking
- [ ] Productivity insights
- [ ] Integration with other apps

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@itrack.app or create an issue in the repository.

## Acknowledgments

- Built with SwiftUI and Supabase
- Icons from SF Symbols
- Design inspired by modern productivity apps
- Thanks to the open-source community for inspiration
