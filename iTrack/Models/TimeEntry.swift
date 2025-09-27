import Foundation

struct TimeEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case duration
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct TimeSummary: Codable {
    let categoryId: UUID
    let categoryName: String
    let categoryColor: String
    let totalDuration: TimeInterval
    let percentage: Double
    let entryCount: Int
    
    var formattedDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TimePeriod: CaseIterable {
    let name: String
    let calendarComponent: Calendar.Component
    let value: Int
    
    static let allCases: [TimePeriod] = [
        TimePeriod(name: "Hour", calendarComponent: .hour, value: 1),
        TimePeriod(name: "Day", calendarComponent: .day, value: 1),
        TimePeriod(name: "Week", calendarComponent: .weekOfYear, value: 1),
        TimePeriod(name: "Month", calendarComponent: .month, value: 1),
        TimePeriod(name: "Year", calendarComponent: .year, value: 1)
    ]
}
