import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: AppDataManager
    
    var body: some View {
        Group {
            if dataManager.currentUser != nil {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var dataManager: AppDataManager
    
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
            
            SummaryView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Summary")
                }
            
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDataManager())
}
