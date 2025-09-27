import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SummaryView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Summary")
                }
                .tag(1)
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            if let userId = authManager.currentUser?.id {
                dataManager.setCurrentUser(userId)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
}
