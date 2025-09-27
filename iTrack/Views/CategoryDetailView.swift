import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let category: Category
    @State private var subcategories: [Category] = []
    @State private var showingAddSubcategory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with category info
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .fill(category.colorValue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: category.iconName)
                                    .foregroundColor(.white)
                                    .font(.title3)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(subcategories.count) subcategories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                // Subcategories or timer
                if subcategories.isEmpty {
                    // Show timer directly
                    TimerView(category: category)
                } else {
                    // Show subcategories
                    CategoryDialView(
                        categories: subcategories,
                        onCategorySelected: { subcategory in
                            // Navigate to timer for this subcategory
                            // This would show a timer view for the specific subcategory
                        }
                    )
                }
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSubcategory = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            loadSubcategories()
        }
        .sheet(isPresented: $showingAddSubcategory) {
            AddCategoryView(parentCategory: category)
        }
    }
    
    private func loadSubcategories() {
        subcategories = dataManager.categories.filter { $0.parentId == category.id }
    }
}

struct TimerView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    let category: Category
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Category display
            VStack(spacing: 16) {
                Circle()
                    .fill(category.colorValue)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: category.iconName)
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                    )
                
                Text(category.name)
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            // Timer display
            VStack(spacing: 8) {
                Text(formatTime(elapsedTime))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)
                
                if let currentEntry = dataManager.currentTimeEntry,
                   currentEntry.categoryId == category.id {
                    Text("Currently tracking")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            // Play/Pause button
            Button(action: {
                if isRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
            }) {
                Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(category.colorValue)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .onAppear {
            if let currentEntry = dataManager.currentTimeEntry,
               currentEntry.categoryId == category.id {
                isRunning = true
                elapsedTime = currentEntry.duration
                startLocalTimer()
            }
        }
        .onDisappear {
            stopLocalTimer()
        }
    }
    
    private func startTimer() {
        Task {
            await dataManager.startTimer(for: category.id)
            isRunning = true
            startLocalTimer()
        }
    }
    
    private func stopTimer() {
        Task {
            await dataManager.stopTimer()
            isRunning = false
            stopLocalTimer()
        }
    }
    
    private func startLocalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let currentEntry = dataManager.currentTimeEntry,
               currentEntry.categoryId == category.id {
                elapsedTime = currentEntry.duration
            }
        }
    }
    
    private func stopLocalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    CategoryDetailView(
        category: Category(
            id: UUID(),
            userId: UUID(),
            name: "Work",
            color: "#007AFF",
            icon: "briefcase.fill",
            parentId: nil,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
    .environmentObject(DataManager())
}
