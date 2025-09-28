import SwiftUI

struct TimerView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var showingAddCategory = false
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("Timer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let user = dataManager.currentUser {
                        Text("Hello, \(user.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                // Timer Display
                VStack(spacing: 20) {
                    if let activeSession = dataManager.activeSession,
                       let category = dataManager.categories.first(where: { $0.id == activeSession.categoryId }) {
                        
                        // Active Timer
                        VStack(spacing: 16) {
                            Text(formatTime(elapsedTime))
                                .font(.system(size: 60, weight: .thin, design: .monospaced))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(category.color.swiftUI)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.name)
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    dataManager.pauseTimer()
                                    stopTimer()
                                }) {
                                    Image(systemName: "pause.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.orange)
                                }
                                
                                Button(action: {
                                    dataManager.stopTimer()
                                    stopTimer()
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        
                    } else {
                        // No Active Timer
                        VStack(spacing: 20) {
                            Text("00:00:00")
                                .font(.system(size: 60, weight: .thin, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Text("Select a category to start")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                }
                
                Spacer()
                
                // Categories Grid
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Categories")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(dataManager.getCategories()) { category in
                            CategoryCard(category: category) {
                                if dataManager.activeSession == nil {
                                    dataManager.startTimer(for: category)
                                    startTimer()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .onAppear {
            if dataManager.activeSession != nil {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let session = dataManager.activeSession {
                elapsedTime = session.duration + Date().timeIntervalSince(session.startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct CategoryCard: View {
    let category: Category
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(category.color.swiftUI)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TimerView()
        .environmentObject(AppDataManager())
}
