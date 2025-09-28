import Foundation
import SwiftUI

// MARK: - Core Data Models
struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var createdAt: Date
    var lastActiveAt: Date
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }
}

struct Category: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: ColorData
    var icon: String
    var userId: UUID
    var createdAt: Date
    var isActive: Bool
    
    init(name: String, color: ColorData, icon: String, userId: UUID) {
        self.name = name
        self.color = color
        self.icon = icon
        self.userId = userId
        self.createdAt = Date()
        self.isActive = true
    }
}

struct TimeSession: Identifiable, Codable {
    let id = UUID()
    var categoryId: UUID
    var userId: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var isActive: Bool
    var createdAt: Date
    
    init(categoryId: UUID, userId: UUID) {
        self.categoryId = categoryId
        self.userId = userId
        self.startTime = Date()
        self.endTime = nil
        self.duration = 0
        self.isActive = true
        self.createdAt = Date()
    }
}

struct Goal: Identifiable, Codable {
    let id = UUID()
    var title: String
    var userId: UUID
    var targetDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    
    init(title: String, userId: UUID, targetDate: Date = Date()) {
        self.title = title
        self.userId = userId
        self.targetDate = targetDate
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
    }
}

struct ColorData: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(swiftUI color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var swiftUI: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Data Manager
class AppDataManager: ObservableObject {
    @Published var currentUser: User?
    @Published var categories: [Category] = []
    @Published var timeSessions: [TimeSession] = []
    @Published var goals: [Goal] = []
    @Published var activeSession: TimeSession?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
        createDefaultCategories()
    }
    
    // MARK: - User Management
    func createUser(name: String) {
        let user = User(name: name)
        currentUser = user
        saveData()
    }
    
    func selectUser(_ user: User) {
        currentUser = user
        var updatedUser = user
        updatedUser.lastActiveAt = Date()
        currentUser = updatedUser
        saveData()
    }
    
    // MARK: - Category Management
    func addCategory(name: String, color: ColorData, icon: String) {
        guard let userId = currentUser?.id else { return }
        let category = Category(name: name, color: color, icon: icon, userId: userId)
        categories.append(category)
        saveData()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveData()
        }
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        timeSessions.removeAll { $0.categoryId == category.id }
        if activeSession?.categoryId == category.id {
            activeSession = nil
        }
        saveData()
    }
    
    // MARK: - Timer Management
    func startTimer(for category: Category) {
        guard let userId = currentUser?.id else { return }
        
        // Stop any active session
        stopTimer()
        
        let session = TimeSession(categoryId: category.id, userId: userId)
        activeSession = session
        timeSessions.append(session)
        saveData()
    }
    
    func stopTimer() {
        guard var session = activeSession else { return }
        
        session.endTime = Date()
        session.duration = session.endTime!.timeIntervalSince(session.startTime)
        session.isActive = false
        
        if let index = timeSessions.firstIndex(where: { $0.id == session.id }) {
            timeSessions[index] = session
        }
        
        activeSession = nil
        saveData()
    }
    
    func pauseTimer() {
        guard var session = activeSession else { return }
        
        session.duration += Date().timeIntervalSince(session.startTime)
        session.isActive = false
        
        if let index = timeSessions.firstIndex(where: { $0.id == session.id }) {
            timeSessions[index] = session
        }
        
        activeSession = nil
        saveData()
    }
    
    func resumeTimer() {
        guard let session = timeSessions.first(where: { $0.id == activeSession?.id }) else { return }
        
        var updatedSession = session
        updatedSession.startTime = Date()
        updatedSession.isActive = true
        
        activeSession = updatedSession
        
        if let index = timeSessions.firstIndex(where: { $0.id == session.id }) {
            timeSessions[index] = updatedSession
        }
        
        saveData()
    }
    
    // MARK: - Goal Management
    func addGoal(title: String) {
        guard let userId = currentUser?.id else { return }
        let goal = Goal(title: title, userId: userId)
        goals.append(goal)
        saveData()
    }
    
    func toggleGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            goals[index].completedAt = goals[index].isCompleted ? Date() : nil
            saveData()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    // MARK: - Data Queries
    func getCategories() -> [Category] {
        return categories.filter { $0.isActive }
    }
    
    func getTimeForCategory(_ category: Category, period: TimePeriod = .today) -> TimeInterval {
        let filteredSessions = timeSessions.filter { session in
            session.categoryId == category.id && isInPeriod(session.startTime, period: period)
        }
        return filteredSessions.reduce(0) { $0 + $1.duration }
    }
    
    func getTotalTime(period: TimePeriod = .today) -> TimeInterval {
        let filteredSessions = timeSessions.filter { session in
            isInPeriod(session.startTime, period: period)
        }
        return filteredSessions.reduce(0) { $0 + $1.duration }
    }
    
    func getActiveGoals() -> [Goal] {
        return goals.filter { !$0.isCompleted && Calendar.current.isDateInToday($0.targetDate) }
    }
    
    func getCompletedGoals() -> [Goal] {
        return goals.filter { $0.isCompleted && Calendar.current.isDateInToday($0.targetDate ?? Date()) }
    }
    
    // MARK: - Private Helpers
    private func isInPeriod(_ date: Date, period: TimePeriod) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            return calendar.isDateInToday(date)
        case .week:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .year:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
    
    private func createDefaultCategories() {
        guard currentUser != nil && categories.isEmpty else { return }
        
        addCategory(name: "Work", color: ColorData(swiftUI: .blue), icon: "briefcase.fill")
        addCategory(name: "Personal", color: ColorData(swiftUI: .green), icon: "person.fill")
        addCategory(name: "Learning", color: ColorData(swiftUI: .purple), icon: "book.fill")
        addCategory(name: "Exercise", color: ColorData(swiftUI: .orange), icon: "figure.run")
    }
    
    private func saveData() {
        if let user = currentUser, let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: "currentUser")
        }
        if let data = try? JSONEncoder().encode(categories) {
            userDefaults.set(data, forKey: "categories")
        }
        if let data = try? JSONEncoder().encode(timeSessions) {
            userDefaults.set(data, forKey: "timeSessions")
        }
        if let data = try? JSONEncoder().encode(goals) {
            userDefaults.set(data, forKey: "goals")
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
        if let data = userDefaults.data(forKey: "categories"),
           let categories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = categories
        }
        if let data = userDefaults.data(forKey: "timeSessions"),
           let sessions = try? JSONDecoder().decode([TimeSession].self, from: data) {
            self.timeSessions = sessions
        }
        if let data = userDefaults.data(forKey: "goals"),
           let goals = try? JSONDecoder().decode([Goal].self, from: data) {
            self.goals = goals
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}
