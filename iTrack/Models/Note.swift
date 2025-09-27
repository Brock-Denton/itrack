import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let content: String
    let isCompleted: Bool
    let order: Int
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case isCompleted = "is_completed"
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
}

struct DailyGoal: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let content: String
    let isCompleted: Bool
    let order: Int
    let date: Date
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case isCompleted = "is_completed"
        case order
        case date
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
    
    var isExpired: Bool {
        Calendar.current.isDateInToday(date) == false
    }
}
