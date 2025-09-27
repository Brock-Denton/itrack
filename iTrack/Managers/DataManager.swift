import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var categories: [Category] = []
    @Published var timeEntries: [TimeEntry] = []
    @Published var goals: [Goal] = []
    
    private let categoriesKey = "iTrackCategories"
    private let timeEntriesKey = "iTrackTimeEntries"
    private let goalsKey = "iTrackGoals"

    init() {
        loadData()
        if categories.isEmpty {
            createDefaultCategories()
        }
    }

    func addCategory(_ category: Category) {
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
        categories.removeAll { $0.parentId == category.id }
        timeEntries.removeAll { $0.categoryId == category.id }
        saveData()
    }

    func getCategories(for userId: UUID, parentId: UUID? = nil) -> [Category] {
        return categories.filter { $0.userId == userId && $0.parentId == parentId }.sorted { $0.order < $1.order }
    }

    func addTimeEntry(_ entry: TimeEntry) {
        timeEntries.append(entry)
        saveData()
    }

    func updateTimeEntry(_ entry: TimeEntry) {
        if let index = timeEntries.firstIndex(where: { $0.id == entry.id }) {
            timeEntries[index] = entry
            saveData()
        }
    }

    func getTimeEntries(for userId: UUID, categoryId: UUID? = nil, period: TimePeriod = .day) -> [TimeEntry] {
        var filteredEntries = timeEntries.filter { $0.userId == userId }
        
        if let categoryId = categoryId {
            filteredEntries = filteredEntries.filter { $0.categoryId == categoryId }
        }
        
        let now = Date()
        switch period {
        case .hour:
            filteredEntries = filteredEntries.filter { $0.startTime > now.addingTimeInterval(-3600) }
        case .day:
            filteredEntries = filteredEntries.filter { Calendar.current.isDate($0.startTime, inSameDayAs: now) }
        case .week:
            filteredEntries = filteredEntries.filter { Calendar.current.isDate($0.startTime, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            filteredEntries = filteredEntries.filter { Calendar.current.isDate($0.startTime, equalTo: now, toGranularity: .month) }
        case .year:
            filteredEntries = filteredEntries.filter { Calendar.current.isDate($0.startTime, equalTo: now, toGranularity: .year) }
        case .all:
            break
        }
        
        return filteredEntries.sorted { $0.startTime > $1.startTime }
    }

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveData()
    }

    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveData()
    }

    func getGoals(for userId: UUID, completed: Bool) -> [Goal] {
        return goals.filter { $0.userId == userId && $0.isCompleted == completed && Calendar.current.isDate($0.goalDate, inSameDayAs: Date()) }
            .sorted { $0.order < $1.order }
    }
    
    func getCompletedGoals(for userId: UUID, within lastHours: Int) -> [Goal] {
        let cutoffDate = Date().addingTimeInterval(TimeInterval(-lastHours * 3600))
        return goals.filter { $0.userId == userId && $0.isCompleted && ($0.completedAt ?? .distantPast) > cutoffDate }
            .sorted { $0.completedAt ?? .distantPast > $1.completedAt ?? .distantPast }
    }

    private func saveData() {
        if let encodedCategories = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encodedCategories, forKey: categoriesKey)
        }
        if let encodedTimeEntries = try? JSONEncoder().encode(timeEntries) {
            UserDefaults.standard.set(encodedTimeEntries, forKey: timeEntriesKey)
        }
        if let encodedGoals = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encodedGoals, forKey: goalsKey)
        }
    }

    private func loadData() {
        if let categoriesData = UserDefaults.standard.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            self.categories = decodedCategories
        }
        if let timeEntriesData = UserDefaults.standard.data(forKey: timeEntriesKey),
           let decodedTimeEntries = try? JSONDecoder().decode([TimeEntry].self, from: timeEntriesData) {
            self.timeEntries = decodedTimeEntries
        }
        if let goalsData = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: goalsData) {
            self.goals = decodedGoals
        }
    }
    
    private func createDefaultCategories() {
        guard let userId = UserManager().currentUser?.id else { return }
        
        let weatherCategory = Category(name: "Weather", color: ColorData(swiftUI: .blue), icon: "cloud.sun", parentId: nil, userId: userId, order: 0, createdAt: Date(), isActive: true)
        let sunny = Category(name: "Sunny", color: ColorData(swiftUI: .orange), icon: "sun.max", parentId: weatherCategory.id, userId: userId, order: 0, createdAt: Date(), isActive: true)
        let rainy = Category(name: "Rainy", color: ColorData(swiftUI: .blue), icon: "cloud.rain", parentId: weatherCategory.id, userId: userId, order: 1, createdAt: Date(), isActive: true)
        let cloudy = Category(name: "Cloudy", color: ColorData(swiftUI: .gray), icon: "cloud", parentId: weatherCategory.id, userId: userId, order: 2, createdAt: Date(), isActive: true)
        
        let workCategory = Category(name: "Work", color: ColorData(swiftUI: .red), icon: "briefcase", parentId: nil, userId: userId, order: 1, createdAt: Date(), isActive: true)
        let personalCategory = Category(name: "Personal", color: ColorData(swiftUI: .green), icon: "person", parentId: nil, userId: userId, order: 2, createdAt: Date(), isActive: true)
        
        categories.append(contentsOf: [weatherCategory, sunny, rainy, cloudy, workCategory, personalCategory])
        saveData()
    }
}

enum TimePeriod: String, CaseIterable, Identifiable {
    case hour, day, week, month, year, all
    var id: String { self.rawValue }
}
