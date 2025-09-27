import Foundation
import Supabase

struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String?
    let googleId: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case googleId = "google_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserProfile: Codable {
    let id: UUID
    let userId: UUID
    let profileImage: String?
    let profileImageType: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case profileImage = "profile_image"
        case profileImageType = "profile_image_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
