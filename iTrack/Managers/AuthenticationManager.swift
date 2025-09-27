import Foundation
import SwiftUI
import Supabase
import GoogleSignIn

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                if let user = session.user {
                    await loadUserProfile(userId: user.id)
                } else {
                    isAuthenticated = false
                    currentUser = nil
                }
            } catch {
                print("Auth check error: \(error)")
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func signInWithUsername(_ username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if username exists
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("username", value: username)
                .execute()
                .value
            
            if let user = response.first {
                // Username exists, sign in
                currentUser = user
                isAuthenticated = true
            } else {
                // Create new user
                let newUser = User(
                    id: UUID(),
                    username: username,
                    email: nil,
                    googleId: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await supabase
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                currentUser = newUser
                isAuthenticated = true
            }
        } catch {
            errorMessage = "Failed to sign in: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let presentingViewController = await UIApplication.shared.windows.first?.rootViewController else {
                throw AuthError.noViewController
            }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let email = user.profile?.email else {
                throw AuthError.noEmail
            }
            
            // Check if user exists in Supabase
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("email", value: email)
                .execute()
                .value
            
            if let existingUser = response.first {
                currentUser = existingUser
                isAuthenticated = true
            } else {
                // Create new user
                let newUser = User(
                    id: UUID(),
                    username: email.components(separatedBy: "@").first ?? "User",
                    email: email,
                    googleId: user.userID,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                try await supabase
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                currentUser = newUser
                isAuthenticated = true
            }
        } catch {
            errorMessage = "Google sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
    }
    
    private func loadUserProfile(userId: UUID) async {
        do {
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let user = response.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }
}

enum AuthError: Error, LocalizedError {
    case noViewController
    case noEmail
    
    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "No view controller available"
        case .noEmail:
            return "No email found in Google account"
        }
    }
}
