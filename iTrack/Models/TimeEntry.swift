import Foundation

struct TimeEntry: Identifiable, Codable {
    let id = UUID()
    var categoryId: UUID
    var userId: UUID
    var startTime: Date
    var endTime: Date?
    var isActive: Bool
    var totalDuration: TimeInterval
    var createdAt: Date
    
    init(categoryId: UUID, userId: UUID, startTime: Date, endTime: Date?, isActive: Bool, totalDuration: TimeInterval, createdAt: Date) {
        self.categoryId = categoryId
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
        self.totalDuration = totalDuration
        self.createdAt = createdAt
    }
}
