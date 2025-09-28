import SwiftUI

@main
struct iTrackApp: App {
    @StateObject private var dataManager = AppDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
