import SwiftUI

struct SummaryView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var userManager = UserManager()
    @State private var selectedPeriod: TimePeriod = .day
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Time Summary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TimePeriod.allCases) { period in
                            Button(action: {
                                selectedPeriod = period
                            }) {
                                Text(period.rawValue.capitalized)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedPeriod == period ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedPeriod == period ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                let timeEntries = dataManager.getTimeEntries(for: userManager.currentUser?.id ?? UUID(), period: selectedPeriod)
                
                VStack {
                    Text("Total Time: \(formatTime(timeEntries.reduce(0) { $0 + $1.totalDuration }))")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if !timeEntries.isEmpty {
                        Text("\(timeEntries.count) sessions tracked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
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
