# iTrack Development Setup Guide

## Current Status: Development Mode

The app is currently configured for **development mode** with production integrations commented out for security. This allows you to:

- ✅ Build and test the app in Xcode
- ✅ See the UI and navigation flow
- ✅ Test with mock data
- ✅ Develop features without external dependencies

## What's Commented Out

### 1. Supabase Integration
- Database connections
- Authentication flows
- Data persistence
- Real-time updates

### 2. Google Sign-In
- OAuth configuration
- Google authentication
- User profile integration

## Development Features

### Mock Authentication
- Username-based login works with mock data
- Users can sign in and navigate the app
- No real authentication or data persistence

### Mock Data
- Categories are created locally
- Time tracking works in memory
- No database persistence

## Next Steps: Production Configuration

When you're ready to configure production integrations:

### 1. Supabase Setup
```bash
# 1. Create Supabase project
# 2. Run the SQL schema from supabase_schema.sql
# 3. Get your project URL and anon key
# 4. Update Config.swift with your credentials
```

### 2. Google Sign-In Setup
```bash
# 1. Create Google Cloud project
# 2. Enable Google Sign-In API
# 3. Create iOS OAuth client
# 4. Download GoogleService-Info.plist
# 5. Add to Xcode project
```

### 3. Uncomment Production Code
- Uncomment Supabase code in `AuthenticationManager.swift`
- Uncomment Supabase code in `DataManager.swift`
- Uncomment Google Sign-In code in `iTrackApp.swift`
- Update `Config.swift` with real credentials

## Security Best Practices

### Configuration Management
- ✅ Credentials are not hardcoded
- ✅ Sensitive files are in `.gitignore`
- ✅ Configuration is centralized in `Config.swift`
- ✅ Development/production flags are in place

### File Security
- ✅ `GoogleService-Info.plist` is ignored by git
- ✅ `.env` files are ignored by git
- ✅ API keys and secrets are ignored by git

## Building and Testing

### Current Development Build
```bash
# 1. Open iTrack.xcodeproj in Xcode
# 2. Build and run (should work without errors)
# 3. Test with mock username login
# 4. Navigate through all screens
```

### Production Build (Future)
```bash
# 1. Configure Supabase and Google Sign-In
# 2. Update Config.swift with real credentials
# 3. Uncomment production code
# 4. Build and test with real data
```

## Configuration Files

### Config.swift
Centralized configuration management with:
- Development/production flags
- Secure credential loading
- Configuration validation
- Mock data controls

### .gitignore
Protects sensitive files from being committed:
- GoogleService-Info.plist
- .env files
- API keys and secrets
- Supabase configuration

## Development Workflow

1. **Current**: Develop with mock data
2. **Test**: Build and run in Xcode
3. **Iterate**: Make UI/UX improvements
4. **Configure**: Set up production integrations
5. **Deploy**: Build for App Store

## Troubleshooting

### Build Errors
- Check that all Swift packages are resolved
- Verify iOS deployment target is 17.0+
- Ensure all files are properly added to the project

### Runtime Issues
- Check console for mock data messages
- Verify navigation flow works
- Test all screens and interactions

### Configuration Issues
- Ensure `Config.swift` is properly configured
- Check development flags are set correctly
- Verify mock data is enabled

## Support

For questions about:
- **Development**: Check this guide and code comments
- **Production Setup**: We'll configure together when ready
- **Issues**: Check console logs and error messages

The app is ready for development and testing. Production integrations will be configured when you're ready to move to the next phase.
