import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: Category?
    @State private var showingCategoryDetail = false
    @State private var showingAddCategory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
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
                    
                    // Current Timer Display
                    if let currentEntry = dataManager.currentTimeEntry,
                       let category = dataManager.categories.first(where: { $0.id == currentEntry.categoryId }) {
                        CurrentTimerView(entry: currentEntry, category: category)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Category Dial
                if dataManager.categories.isEmpty {
                    EmptyCategoriesView()
                } else {
                    CategoryDialView(
                        categories: dataManager.categories.filter { $0.parentId == nil },
                        onCategorySelected: { category in
                            selectedCategory = category
                            showingCategoryDetail = true
                        }
                    )
                }
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCategoryDetail) {
            if let category = selectedCategory {
                CategoryDetailView(category: category)
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
}

struct CurrentTimerView: View {
    let entry: TimeEntry
    let category: Category
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.colorValue)
                .frame(width: 12, height: 12)
            
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(entry.formattedDuration)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptyCategoriesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Categories Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add your first category to start tracking time")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
