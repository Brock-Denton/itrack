import Foundation

struct Goal: Identifiable, Codable {
    let id = UUID()
    var title: String
    var userId: UUID
    var goalDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var order: Int
    var createdAt: Date
    
    init(title: String, userId: UUID, goalDate: Date, isCompleted: Bool, completedAt: Date?, order: Int, createdAt: Date) {
        self.title = title
        self.userId = userId
        self.goalDate = goalDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.order = order
        self.createdAt = createdAt
    }
}
