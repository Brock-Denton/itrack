import SwiftUI
// import Supabase
// import GoogleSignIn

@main
struct iTrackApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var dataManager = DataManager()
    
    init() {
        // TODO: Configure Google Sign-In when ready
        // guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
        //     print("GoogleService-Info.plist not found")
        //     return
        // }
        // 
        // guard let plist = NSDictionary(contentsOfFile: path),
        //       let clientId = plist["CLIENT_ID"] as? String else {
        //     print("Could not read CLIENT_ID from GoogleService-Info.plist")
        //     return
        // }
        // 
        // GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        
        print("iTrack app initialized - Google Sign-In not configured yet")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
                .onAppear {
                    authManager.checkAuthStatus()
                }
        }
    }
}
