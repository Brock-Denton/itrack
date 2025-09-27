//
//  ContentView.swift
//  iTrack
//
//  Created by Brock Denton on 9/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    
    var body: some View {
        Group {
            if userManager.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(userManager)
    }
}

struct MainTabView: View {
    @EnvironmentObject var userManager: UserManager
    
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
        }
    }
}

#Preview {
    ContentView()
}
