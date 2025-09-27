import Foundation

// MARK: - Configuration Manager
// This file handles secure configuration management for the iTrack app
// Production credentials should be stored securely and not committed to git

struct Config {
    
    // MARK: - Supabase Configuration
    struct Supabase {
        // TODO: Replace with actual Supabase credentials
        // These should be loaded from a secure source in production
        static let url = "YOUR_SUPABASE_URL"
        static let anonKey = "YOUR_SUPABASE_ANON_KEY"
        
        // For development, you can use environment variables or a secure config file
        // Example: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "fallback_url"
    }
    
    // MARK: - Google Sign-In Configuration
    struct GoogleSignIn {
        // TODO: Replace with actual Google Sign-In configuration
        // The GoogleService-Info.plist should be added to the project
        // and the CLIENT_ID should be read from there
        static let clientId = "YOUR_GOOGLE_CLIENT_ID"
    }
    
    // MARK: - App Configuration
    struct App {
        static let name = "iTrack"
        static let version = "1.0.0"
        static let bundleId = "com.itrack.app"
    }
    
    // MARK: - Development Flags
    struct Development {
        static let isProduction = false
        static let enableLogging = true
        static let useMockData = true // Set to false when Supabase is configured
    }
}

// MARK: - Secure Configuration Loader
// This class can be extended to load configuration from secure sources
class SecureConfigLoader {
    
    static func loadSupabaseConfig() -> (url: String, key: String)? {
        // TODO: Implement secure configuration loading
        // Options:
        // 1. Environment variables
        // 2. Secure keychain storage
        // 3. Encrypted configuration file
        // 4. Remote configuration service
        
        if Config.Development.isProduction {
            // Load from secure source in production
            return nil
        } else {
            // Use development configuration
            return (url: Config.Supabase.url, key: Config.Supabase.anonKey)
        }
    }
    
    static func loadGoogleSignInConfig() -> String? {
        // TODO: Implement secure Google Sign-In configuration loading
        if Config.Development.isProduction {
            // Load from secure source in production
            return nil
        } else {
            // Use development configuration
            return Config.GoogleSignIn.clientId
        }
    }
}

// MARK: - Configuration Validation
extension Config {
    
    static func validateConfiguration() -> Bool {
        // TODO: Add configuration validation
        // Check if all required configuration is present
        
        if Config.Development.useMockData {
            print("⚠️  Using mock data - Supabase not configured")
            return true
        }
        
        // Validate Supabase configuration
        if Config.Supabase.url == "YOUR_SUPABASE_URL" || Config.Supabase.anonKey == "YOUR_SUPABASE_ANON_KEY" {
            print("❌ Supabase configuration not set")
            return false
        }
        
        // Validate Google Sign-In configuration
        if Config.GoogleSignIn.clientId == "YOUR_GOOGLE_CLIENT_ID" {
            print("❌ Google Sign-In configuration not set")
            return false
        }
        
        print("✅ Configuration validated successfully")
        return true
    }
}
