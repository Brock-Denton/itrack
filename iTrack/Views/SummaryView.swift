import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var selectedPeriod: TimePeriod = .today
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Total Time
                VStack(spacing: 8) {
                    Text(formatTime(dataManager.getTotalTime(period: selectedPeriod)))
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Total Time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Categories Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Categories")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(dataManager.getCategories()) { category in
                                CategorySummaryRow(
                                    category: category,
                                    timeSpent: dataManager.getTimeForCategory(category, period: selectedPeriod),
                                    totalTime: dataManager.getTotalTime(period: selectedPeriod)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CategorySummaryRow: View {
    let category: Category
    let timeSpent: TimeInterval
    let totalTime: TimeInterval
    
    private var percentage: Double {
        guard totalTime > 0 else { return 0 }
        return timeSpent / totalTime
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(category.color.swiftUI)
                    .frame(width: 40, height: 40)
                
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            // Category Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time
            Text(formatTime(timeSpent))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    SummaryView()
        .environmentObject(AppDataManager())
}