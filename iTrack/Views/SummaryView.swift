import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: TimePeriod = .allCases[1] // Default to Day
    @State private var timeSummaries: [TimeSummary] = []
    @State private var isLoading = false
    @State private var selectedCategory: Category?
    @State private var showingCategoryDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Time Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    // Period selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TimePeriod.allCases, id: \.name) { period in
                                Button(action: {
                                    selectedPeriod = period
                                    loadTimeSummary()
                                }) {
                                    Text(period.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedPeriod.name == period.name ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedPeriod.name == period.name ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if timeSummaries.isEmpty {
                    EmptySummaryView()
                } else {
                    // Summary content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Total time display
                            TotalTimeView(summaries: timeSummaries)
                            
                            // Category breakdown
                            CategoryBreakdownView(
                                summaries: timeSummaries,
                                onCategorySelected: { summary in
                                    if let category = dataManager.categories.first(where: { $0.id == summary.categoryId }) {
                                        selectedCategory = category
                                        showingCategoryDetail = true
                                    }
                                }
                            )
                            
                            // Legend
                            LegendView(summaries: timeSummaries)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            loadTimeSummary()
        }
        .sheet(isPresented: $showingCategoryDetail) {
            if let category = selectedCategory {
                CategoryDetailView(category: category)
            }
        }
    }
    
    private func loadTimeSummary() {
        isLoading = true
        Task {
            let summaries = await dataManager.getTimeSummary(for: selectedPeriod)
            await MainActor.run {
                timeSummaries = summaries
                isLoading = false
            }
        }
    }
}

struct TotalTimeView: View {
    let summaries: [TimeSummary]
    
    private var totalTime: TimeInterval {
        summaries.reduce(0) { $0 + $1.totalDuration }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Total Time")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(formatTotalTime(totalTime))
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CategoryBreakdownView: View {
    let summaries: [TimeSummary]
    let onCategorySelected: (TimeSummary) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(summaries, id: \.categoryId) { summary in
                CategorySummaryRowView(summary: summary) {
                    onCategorySelected(summary)
                }
            }
        }
    }
}

struct CategorySummaryRowView: View {
    let summary: TimeSummary
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Color indicator
                Circle()
                    .fill(Color(hex: summary.categoryColor) ?? .gray)
                    .frame(width: 16, height: 16)
                
                // Category name
                Text(summary.categoryName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Time and percentage
                VStack(alignment: .trailing, spacing: 2) {
                    Text(summary.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(summary.percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegendView: View {
    let summaries: [TimeSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Legend")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(summaries, id: \.categoryId) { summary in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: summary.categoryColor) ?? .gray)
                        .frame(width: 12, height: 12)
                    
                    Text(summary.categoryName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(summary.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptySummaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Start tracking time to see your summary")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    SummaryView()
        .environmentObject(DataManager())
}
