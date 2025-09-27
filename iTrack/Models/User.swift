import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    let username: String
    let createdAt: Date
    var lastActiveAt: Date
    let timezone: String
    
    init(username: String, createdAt: Date, lastActiveAt: Date, timezone: String) {
        self.username = username
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.timezone = timezone
    }
}
