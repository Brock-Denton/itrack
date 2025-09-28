import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let user = dataManager.currentUser {
                        Text("Hello, \(user.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                // Settings Options
                VStack(spacing: 16) {
                    SettingsRow(
                        icon: "person.circle",
                        title: "Profile",
                        subtitle: dataManager.currentUser?.name ?? "No user"
                    ) {
                        // Profile action
                    }
                    
                    SettingsRow(
                        icon: "chart.bar",
                        title: "Statistics",
                        subtitle: "View detailed analytics"
                    ) {
                        // Statistics action
                    }
                    
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "Reset Data",
                        subtitle: "Clear all data and start fresh"
                    ) {
                        showingResetAlert = true
                    }
                    
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        subtitle: "Get help using the app"
                    ) {
                        // Help action
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // App Info
                VStack(spacing: 8) {
                    Text("iTrack")
                        .font(.headline)
                    
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your data. This action cannot be undone.")
        }
    }
    
    private func resetAllData() {
        dataManager.categories.removeAll()
        dataManager.timeSessions.removeAll()
        dataManager.goals.removeAll()
        dataManager.activeSession = nil
        // Note: We keep the current user, just reset their data
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppDataManager())
}
