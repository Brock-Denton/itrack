import Foundation
import SwiftUI
import UIKit

struct Category: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: ColorData
    var icon: String
    var parentId: UUID?
    var userId: UUID
    var order: Int
    var createdAt: Date
    var isActive: Bool
    
    init(name: String, color: ColorData, icon: String, parentId: UUID?, userId: UUID, order: Int, createdAt: Date, isActive: Bool) {
        self.name = name
        self.color = color
        self.icon = icon
        self.parentId = parentId
        self.userId = userId
        self.order = order
        self.createdAt = createdAt
        self.isActive = isActive
    }
}

struct ColorData: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    var swiftUI: Color {
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    init(uiColor: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }

    init(swiftUI: Color) {
        self.init(uiColor: UIColor(swiftUI))
    }
}
