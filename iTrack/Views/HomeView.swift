import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var timerManager = TimerManager()
    @StateObject private var userManager = UserManager()
    @State private var selectedCategory: Category?
    @State private var showingSubcategories = false
    @State private var showingAddCategory = false
    @State private var showingRenameCategory = false
    @State private var currentRound = 1
    @State private var categoryToRename: Category?
    @State private var newCategoryName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack {
                    HStack {
                        Text("iTrack")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let user = userManager.currentUser {
                        Text("Welcome, \(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Round \(currentRound)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                }
                .padding(.top)
                
                Spacer()
                
                if showingSubcategories {
                    CategoryDialViewWithProgress(
                        categories: dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: selectedCategory?.id),
                        onCategorySelected: { category in
                            if currentRound == 1 {
                                currentRound = 2
                            } else {
                                selectedCategory = category
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
                        onCategoryLongPress: { category in
                            categoryToRename = category
                            newCategoryName = category.name
                            showingRenameCategory = true
                        },
                        isTimerRunning: timerManager.isTimerRunning,
                        currentDuration: timerManager.currentDuration,
                        currentRound: currentRound
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
                    CategoryDialViewWithProgress(
                        categories: dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: nil),
                        onCategorySelected: { category in
                            selectedCategory = category
                            let subcategories = dataManager.getCategories(for: userManager.currentUser?.id ?? UUID(), parentId: category.id)
                            if !subcategories.isEmpty {
                                showingSubcategories = true
                            } else {
                                if currentRound == 1 {
                                    currentRound = 2
                                } else {
                                    timerManager.startTracking(for: category, userId: userManager.currentUser?.id ?? UUID())
                                }
                            }
                        },
                        onTimerToggled: { category in
                            if timerManager.isTimerRunning {
                                timerManager.pauseTracking()
                            } else {
                                timerManager.resumeTracking()
                            }
                        },
                        onCategoryLongPress: { category in
                            categoryToRename = category
                            newCategoryName = category.name
                            showingRenameCategory = true
                        },
                        isTimerRunning: timerManager.isTimerRunning,
                        currentDuration: timerManager.currentDuration,
                        currentRound: currentRound
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
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(dataManager: dataManager, userManager: userManager, isPresented: $showingAddCategory)
        }
        .sheet(isPresented: $showingRenameCategory) {
            RenameCategoryView(category: categoryToRename, dataManager: dataManager, isPresented: $showingRenameCategory)
        }
    }
    
    private func getCategoryName(for categoryId: UUID) -> String {
        return dataManager.categories.first { $0.id == categoryId }?.name ?? "Unknown"
    }
}
