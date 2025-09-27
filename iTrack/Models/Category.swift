import Foundation
import SwiftUI

struct Category: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let name: String
    let color: String
    let icon: String
    let parentId: UUID?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case color
        case icon
        case parentId = "parent_id"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var colorValue: Color {
        Color(hex: color) ?? .gray
    }
    
    var iconName: String {
        icon.isEmpty ? "circle.fill" : icon
    }
}

struct CategoryWithChildren: Codable, Identifiable {
    let category: Category
    let children: [Category]
    
    var id: UUID { category.id }
}

// Default category templates
struct CategoryTemplate {
    let name: String
    let color: String
    let icon: String
    let children: [CategoryTemplate]
    
    static let defaultTemplates: [CategoryTemplate] = [
        CategoryTemplate(
            name: "Work",
            color: "#007AFF",
            icon: "briefcase.fill",
            children: [
                CategoryTemplate(name: "Meetings", color: "#5AC8FA", icon: "person.2.fill", children: []),
                CategoryTemplate(name: "Coding", color: "#34C759", icon: "laptopcomputer", children: []),
                CategoryTemplate(name: "Planning", color: "#FF9500", icon: "list.bullet", children: [])
            ]
        ),
        CategoryTemplate(
            name: "Personal",
            color: "#FF3B30",
            icon: "person.fill",
            children: [
                CategoryTemplate(name: "Exercise", color: "#FF2D92", icon: "figure.run", children: []),
                CategoryTemplate(name: "Reading", color: "#AF52DE", icon: "book.fill", children: []),
                CategoryTemplate(name: "Hobbies", color: "#FF6B6B", icon: "heart.fill", children: [])
            ]
        ),
        CategoryTemplate(
            name: "Learning",
            color: "#30D158",
            icon: "graduationcap.fill",
            children: [
                CategoryTemplate(name: "Online Courses", color: "#64D2FF", icon: "play.rectangle.fill", children: []),
                CategoryTemplate(name: "Research", color: "#FF9F0A", icon: "magnifyingglass", children: []),
                CategoryTemplate(name: "Practice", color: "#FF453A", icon: "pencil", children: [])
            ]
        )
    ]
}
