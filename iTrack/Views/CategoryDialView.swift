import SwiftUI

struct CategoryDialView: View {
    let categories: [Category]
    let onCategorySelected: (Category) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) - 40
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    .frame(width: size, height: size)
                    .position(center)
                
                // Category segments
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    CategorySegmentView(
                        category: category,
                        index: index,
                        total: categories.count,
                        center: center,
                        radius: radius
                    )
                    .onTapGesture {
                        onCategorySelected(category)
                    }
                }
            }
        }
        .frame(height: 300)
        .padding(.horizontal, 20)
    }
}

struct CategorySegmentView: View {
    let category: Category
    let index: Int
    let total: Int
    let center: CGPoint
    let radius: CGFloat
    
    private var startAngle: Double {
        (Double(index) / Double(total)) * 2 * .pi - .pi / 2
    }
    
    private var endAngle: Double {
        (Double(index + 1) / Double(total)) * 2 * .pi - .pi / 2
    }
    
    private var segmentCenter: CGPoint {
        let midAngle = (startAngle + endAngle) / 2
        let segmentRadius = radius * 0.7
        return CGPoint(
            x: center.x + cos(midAngle) * segmentRadius,
            y: center.y + sin(midAngle) * segmentRadius
        )
    }
    
    var body: some View {
        ZStack {
            // Segment arc
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(startAngle),
                    endAngle: .radians(endAngle),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(category.colorValue.opacity(0.3))
            .overlay(
                Path { path in
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .radians(startAngle),
                        endAngle: .radians(endAngle),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .stroke(category.colorValue, lineWidth: 2)
            )
            
            // Category icon and name
            VStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(category.colorValue)
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .position(segmentCenter)
        }
    }
}

#Preview {
    CategoryDialView(
        categories: [
            Category(
                id: UUID(),
                userId: UUID(),
                name: "Work",
                color: "#007AFF",
                icon: "briefcase.fill",
                parentId: nil,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Category(
                id: UUID(),
                userId: UUID(),
                name: "Personal",
                color: "#FF3B30",
                icon: "person.fill",
                parentId: nil,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Category(
                id: UUID(),
                userId: UUID(),
                name: "Learning",
                color: "#30D158",
                icon: "graduationcap.fill",
                parentId: nil,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ],
        onCategorySelected: { _ in }
    )
    .frame(height: 300)
}
