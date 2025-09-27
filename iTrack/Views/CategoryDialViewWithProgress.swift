import SwiftUI

struct CategoryDialViewWithProgress: View {
    let categories: [Category]
    let onCategorySelected: (Category) -> Void
    let onTimerToggled: (Category) -> Void
    let onCategoryLongPress: (Category) -> Void
    let isTimerRunning: Bool
    let currentDuration: TimeInterval
    let currentRound: Int
    
    private let circleRadius: CGFloat = 120
    private let categoryRadius: CGFloat = 80
    private let progressBarWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            backgroundCircle
            progressBar
            categoryButtons
            centerControls
        }
        .frame(width: circleRadius * 2 + 80, height: circleRadius * 2 + 80)
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(Color.gray.opacity(0.1))
            .frame(width: circleRadius * 2, height: circleRadius * 2)
    }
    
    private var progressBar: some View {
        ZStack {
            // Background progress circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: progressBarWidth)
                .frame(width: circleRadius * 2 + 20, height: circleRadius * 2 + 20)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: progressBarWidth, lineCap: .round)
                )
                .frame(width: circleRadius * 2 + 20, height: circleRadius * 2 + 20)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
        }
    }
    
    private var categoryButtons: some View {
        ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
            categoryButton(at: index, category: category)
        }
    }
    
    private func categoryButton(at index: Int, category: Category) -> some View {
        let angle = Double(index) * (2 * .pi / Double(categories.count)) - .pi / 2
        let x = cos(angle) * categoryRadius
        let y = sin(angle) * categoryRadius
        
        return Button(action: {
            onCategorySelected(category)
        }) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 60, height: 60)
            .background(category.color.swiftUI)
            .clipShape(Circle())
            .scaleEffect(currentRound == 2 && !isTimerRunning ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: currentRound)
        }
        .offset(x: x, y: y)
        .onLongPressGesture {
            onCategoryLongPress(category)
        }
    }
    
    private var centerControls: some View {
        VStack(spacing: 8) {
            if currentRound == 2 && !isTimerRunning {
                // Round 2 - Show timer start button
                Button(action: {
                    if let firstCategory = categories.first {
                        onTimerToggled(firstCategory)
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Start Timer")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            } else if isTimerRunning {
                timerRunningView
            } else {
                // Round 1 - Show selection prompt
                VStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("Select Category")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var timerRunningView: some View {
        VStack(spacing: 8) {
            Button(action: {
                if let firstCategory = categories.first {
                    onTimerToggled(firstCategory)
                }
            }) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            Text(formatTime(currentDuration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressPercentage: Double {
        if currentRound == 1 {
            return 0.0
        } else if currentRound == 2 && !isTimerRunning {
            return 0.5
        } else {
            // Calculate progress based on timer duration (example: 25 minutes = 100%)
            let maxDuration: TimeInterval = 25 * 60 // 25 minutes
            return min(currentDuration / maxDuration, 1.0)
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
