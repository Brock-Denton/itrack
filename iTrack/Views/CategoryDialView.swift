import SwiftUI

struct CategoryDialView: View {
    let categories: [Category]
    let onCategorySelected: (Category) -> Void
    let onTimerToggled: (Category) -> Void
    let isTimerRunning: Bool
    let currentDuration: TimeInterval
    
    private let circleRadius: CGFloat = 120
    private let categoryRadius: CGFloat = 80
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: circleRadius * 2, height: circleRadius * 2)
            
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                let angle = Double(index) * (2 * .pi / Double(categories.count)) - .pi / 2
                let x = cos(angle) * categoryRadius
                let y = sin(angle) * categoryRadius
                
                Button(action: {
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
                }
                .offset(x: x, y: y)
            }
            
            VStack(spacing: 8) {
                if isTimerRunning {
                    Button(action: {
                        if let currentCategory = categories.first {
                            onTimerToggled(currentCategory)
                        }
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                    
                    Text(formatTime(currentDuration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        if let currentCategory = categories.first {
                            onTimerToggled(currentCategory)
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .frame(width: circleRadius * 2 + 80, height: circleRadius * 2 + 80)
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
