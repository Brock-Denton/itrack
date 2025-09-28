import SwiftUI

struct SummaryView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var userManager = UserManager()
    @State private var selectedPeriod: TimePeriod = .day
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top percentage breakdown
                topPercentageBreakdown
                
                // Circular dial with time period filters
                circularDialSection
                
                // Categories list
                categoriesList
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var topPercentageBreakdown: some View {
        let categories = getCategoriesWithTime()
        let totalTime = categories.reduce(0) { $0 + $1.totalTime }
        
        return HStack(spacing: 20) {
            ForEach(categories.prefix(3), id: \.category.id) { categoryData in
                VStack(spacing: 4) {
                    Circle()
                        .fill(categoryData.category.color.swiftUI)
                        .frame(width: 8, height: 8)
                    
                    Text(categoryData.category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int((categoryData.totalTime / max(totalTime, 1)) * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var circularDialSection: some View {
        let categories = getCategoriesWithTime()
        let totalTime = categories.reduce(0) { $0 + $1.totalTime }
        
        return VStack(spacing: 20) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Category segments
                ForEach(Array(categories.enumerated()), id: \.element.category.id) { index, categoryData in
                    let startAngle = getStartAngle(for: index, categories: categories)
                    let endAngle = getEndAngle(for: index, categories: categories)
                    
                    Circle()
                        .trim(from: startAngle, to: endAngle)
                        .stroke(
                            categoryData.category.color.swiftUI,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                }
                
                // Center content
                VStack(spacing: 8) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(selectedPeriod == .day ? .blue : .secondary)
                        .onTapGesture { selectedPeriod = .day }
                    
                    Text("Week")
                        .font(.caption)
                        .foregroundColor(selectedPeriod == .week ? .blue : .secondary)
                        .onTapGesture { selectedPeriod = .week }
                    
                    Text("Month")
                        .font(.caption)
                        .foregroundColor(selectedPeriod == .month ? .blue : .secondary)
                        .onTapGesture { selectedPeriod = .month }
                    
                    Text("Year")
                        .font(.caption)
                        .foregroundColor(selectedPeriod == .year ? .blue : .secondary)
                        .onTapGesture { selectedPeriod = .year }
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    private var categoriesList: some View {
        let categories = getCategoriesWithTime()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal, 20)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(categories, id: \.category.id) { categoryData in
                        categoryRow(categoryData: categoryData)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func categoryRow(categoryData: CategoryTimeData) -> some View {
        let goalPercentage = getGoalPercentage(for: categoryData.category)
        let actualPercentage = getActualPercentage(for: categoryData)
        
        return HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(categoryData.category.color.swiftUI)
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryData.category.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            
            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(categoryData.category.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Goal of \(Int(goalPercentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Time
            Text(formatTime(categoryData.totalTime))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(categoryData.category.color.swiftUI)
        .cornerRadius(12)
    }
    
    private func getCategoriesWithTime() -> [CategoryTimeData] {
        let userId = userManager.currentUser?.id ?? UUID()
        let timeEntries = dataManager.getTimeEntries(for: userId, period: selectedPeriod)
        let categories = dataManager.getCategories(for: userId, parentId: nil)
        
        return categories.map { category in
            let totalTime = timeEntries
                .filter { $0.categoryId == category.id }
                .reduce(0) { $0 + $1.totalDuration }
            
            return CategoryTimeData(category: category, totalTime: totalTime)
        }
        .sorted { $0.totalTime > $1.totalTime }
    }
    
    private func getStartAngle(for index: Int, categories: [CategoryTimeData]) -> Double {
        let totalTime = categories.reduce(0) { $0 + $1.totalTime }
        guard totalTime > 0 else { return 0 }
        
        var cumulativeAngle = 0.0
        for i in 0..<index {
            let percentage = categories[i].totalTime / totalTime
            cumulativeAngle += percentage
        }
        return cumulativeAngle
    }
    
    private func getEndAngle(for index: Int, categories: [CategoryTimeData]) -> Double {
        let totalTime = categories.reduce(0) { $0 + $1.totalTime }
        guard totalTime > 0 else { return 0 }
        
        var cumulativeAngle = 0.0
        for i in 0...index {
            let percentage = categories[i].totalTime / totalTime
            cumulativeAngle += percentage
        }
        return cumulativeAngle
    }
    
    private func getGoalPercentage(for category: Category) -> Double {
        // For now, return a default goal percentage
        // This could be stored in the Category model or calculated based on user preferences
        return 0.3 // 30% default goal
    }
    
    private func getActualPercentage(for categoryData: CategoryTimeData) -> Double {
        let allCategories = getCategoriesWithTime()
        let totalTime = allCategories.reduce(0) { $0 + $1.totalTime }
        guard totalTime > 0 else { return 0 }
        
        return categoryData.totalTime / totalTime
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours) hrs \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

struct CategoryTimeData {
    let category: Category
    let totalTime: TimeInterval
}
