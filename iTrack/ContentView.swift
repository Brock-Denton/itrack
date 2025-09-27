import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var username = ""
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated, username: $username)
            }
        }
        .animation(.easeInOut, value: isAuthenticated)
    }
}

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var username: String
    @State private var inputUsername = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("iTrack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Track your time, achieve your goals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Login Form
            VStack(spacing: 20) {
                // Username Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your username", text: $inputUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Sign In Button
                Button(action: {
                    username = inputUsername
                    isAuthenticated = true
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(inputUsername.isEmpty)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SummaryView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Summary")
                }
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to iTrack!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Time tracking features coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

struct SummaryView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Time Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Analytics coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Summary")
        }
    }
}

struct NotesView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Daily Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Goal tracking coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Notes")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("User settings coming soon...")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}