import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var timerManager = TimerManager()
    @StateObject private var userManager = UserManager()
    @State private var selectedCategory: Category?
    @State private var showingSubcategories = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack {
                    Text("iTrack")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let user = userManager.currentUser {
                        Text("Welcome, \(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                if showingSubcategories {
                    CategoryDialView(
                        categories: dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: selectedCategory?.id),
                        onCategorySelected: { category in
                            selectedCategory = category
                            timerManager.startTracking(for: category, userId: userManager.currentUser?.id ?? UUID())
                        },
                        onTimerToggled: { category in
                            if timerManager.isTimerRunning {
                                timerManager.pauseTracking()
                            } else {
                                timerManager.resumeTracking()
                            }
                        },
                        isTimerRunning: timerManager.isTimerRunning,
                        currentDuration: timerManager.currentDuration
                    )
                    
                    Button(action: {
                        showingSubcategories = false
                        selectedCategory = nil
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back to Categories")
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    CategoryDialView(
                        categories: dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: nil),
                        onCategorySelected: { category in
                            selectedCategory = category
                            let subcategories = dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: category.id)
                            if !subcategories.isEmpty {
                                showingSubcategories = true
                            } else {
                                timerManager.startTracking(for: category, userId: userManager.currentUser?.id ?? UUID())
                            }
                        },
                        onTimerToggled: { category in
                            if timerManager.isTimerRunning {
                                timerManager.pauseTracking()
                            } else {
                                timerManager.resumeTracking()
                            }
                        },
                        isTimerRunning: timerManager.isTimerRunning,
                        currentDuration: timerManager.currentDuration
                    )
                }
                
                Spacer()
                
                if timerManager.isTimerRunning {
                    VStack {
                        Text("Currently Tracking")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        if let currentTimer = timerManager.currentTimer {
                            Text("Category: \(getCategoryName(for: currentTimer.categoryId))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func getCategoryName(for categoryId: UUID) -> String {
        return dataManager.categories.first { $0.id == categoryId }?.name ?? "Unknown"
    }
}
