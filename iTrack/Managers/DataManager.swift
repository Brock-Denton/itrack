import Foundation
import SwiftUI
import Supabase

@MainActor
class DataManager: ObservableObject {
    @Published var categories: [Category] = []
    @Published var timeEntries: [TimeEntry] = []
    @Published var currentTimeEntry: TimeEntry?
    @Published var notes: [Note] = []
    @Published var dailyGoals: [DailyGoal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    private var timer: Timer?
    private var currentUserId: UUID?
    
    func setCurrentUser(_ userId: UUID) {
        currentUserId = userId
        loadInitialData()
    }
    
    // MARK: - Categories
    
    func loadCategories() async {
        guard let userId = currentUserId else { return }
        
        do {
            let response: [Category] = try await supabase
                .from("categories")
                .select()
                .eq("user_id", value: userId)
                .eq("is_active", value: true)
                .order("created_at")
                .execute()
                .value
            
            categories = response
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }
    
    func createCategory(name: String, color: String, icon: String, parentId: UUID? = nil) async {
        guard let userId = currentUserId else { return }
        
        let newCategory = Category(
            id: UUID(),
            userId: userId,
            name: name,
            color: color,
            icon: icon,
            parentId: parentId,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await supabase
                .from("categories")
                .insert(newCategory)
                .execute()
            
            categories.append(newCategory)
        } catch {
            errorMessage = "Failed to create category: \(error.localizedDescription)"
        }
    }
    
    func updateCategory(_ category: Category) async {
        do {
            try await supabase
                .from("categories")
                .update(category)
                .eq("id", value: category.id)
                .execute()
            
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = category
            }
        } catch {
            errorMessage = "Failed to update category: \(error.localizedDescription)"
        }
    }
    
    func deleteCategory(_ category: Category) async {
        do {
            try await supabase
                .from("categories")
                .update(["is_active": false])
                .eq("id", value: category.id)
                .execute()
            
            categories.removeAll { $0.id == category.id }
        } catch {
            errorMessage = "Failed to delete category: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Time Entries
    
    func startTimer(for categoryId: UUID) async {
        guard let userId = currentUserId else { return }
        
        // Stop any existing timer
        if let currentEntry = currentTimeEntry {
            await stopTimer()
        }
        
        let newEntry = TimeEntry(
            id: UUID(),
            userId: userId,
            categoryId: categoryId,
            startTime: Date(),
            endTime: nil,
            duration: 0,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await supabase
                .from("time_entries")
                .insert(newEntry)
                .execute()
            
            currentTimeEntry = newEntry
            startLocalTimer()
        } catch {
            errorMessage = "Failed to start timer: \(error.localizedDescription)"
        }
    }
    
    func stopTimer() async {
        guard let entry = currentTimeEntry else { return }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(entry.startTime)
        
        let updatedEntry = TimeEntry(
            id: entry.id,
            userId: entry.userId,
            categoryId: entry.categoryId,
            startTime: entry.startTime,
            endTime: endTime,
            duration: duration,
            isActive: false,
            createdAt: entry.createdAt,
            updatedAt: Date()
        )
        
        do {
            try await supabase
                .from("time_entries")
                .update(updatedEntry)
                .eq("id", value: entry.id)
                .execute()
            
            currentTimeEntry = nil
            stopLocalTimer()
        } catch {
            errorMessage = "Failed to stop timer: \(error.localizedDescription)"
        }
    }
    
    private func startLocalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCurrentTimer()
            }
        }
    }
    
    private func stopLocalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentTimer() {
        guard let entry = currentTimeEntry else { return }
        
        let duration = Date().timeIntervalSince(entry.startTime)
        let updatedEntry = TimeEntry(
            id: entry.id,
            userId: entry.userId,
            categoryId: entry.categoryId,
            startTime: entry.startTime,
            endTime: nil,
            duration: duration,
            isActive: true,
            createdAt: entry.createdAt,
            updatedAt: Date()
        )
        
        currentTimeEntry = updatedEntry
    }
    
    func loadTimeEntries(for period: TimePeriod? = nil) async {
        guard let userId = currentUserId else { return }
        
        var query = supabase
            .from("time_entries")
            .select()
            .eq("user_id", value: userId)
            .order("start_time", ascending: false)
        
        if let period = period {
            let startDate = getStartDate(for: period)
            query = query.gte("start_time", value: startDate.iso8601String)
        }
        
        do {
            let response: [TimeEntry] = try await query.execute().value
            timeEntries = response
        } catch {
            errorMessage = "Failed to load time entries: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Notes and Daily Goals
    
    func loadNotes() async {
        guard let userId = currentUserId else { return }
        
        do {
            let response: [Note] = try await supabase
                .from("notes")
                .select()
                .eq("user_id", value: userId)
                .order("order")
                .execute()
                .value
            
            notes = response
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
        }
    }
    
    func createNote(content: String) async {
        guard let userId = currentUserId else { return }
        
        let newNote = Note(
            id: UUID(),
            userId: userId,
            content: content,
            isCompleted: false,
            order: notes.count,
            createdAt: Date(),
            updatedAt: Date(),
            completedAt: nil
        )
        
        do {
            try await supabase
                .from("notes")
                .insert(newNote)
                .execute()
            
            notes.append(newNote)
        } catch {
            errorMessage = "Failed to create note: \(error.localizedDescription)"
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            try await supabase
                .from("notes")
                .update(note)
                .eq("id", value: note.id)
                .execute()
            
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
    
    func loadDailyGoals() async {
        guard let userId = currentUserId else { return }
        
        do {
            let response: [DailyGoal] = try await supabase
                .from("daily_goals")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .order("order")
                .execute()
                .value
            
            dailyGoals = response
        } catch {
            errorMessage = "Failed to load daily goals: \(error.localizedDescription)"
        }
    }
    
    func createDailyGoal(content: String) async {
        guard let userId = currentUserId else { return }
        
        let newGoal = DailyGoal(
            id: UUID(),
            userId: userId,
            content: content,
            isCompleted: false,
            order: dailyGoals.filter { $0.date.isToday() }.count,
            date: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            completedAt: nil
        )
        
        do {
            try await supabase
                .from("daily_goals")
                .insert(newGoal)
                .execute()
            
            dailyGoals.append(newGoal)
        } catch {
            errorMessage = "Failed to create daily goal: \(error.localizedDescription)"
        }
    }
    
    func updateDailyGoal(_ goal: DailyGoal) async {
        do {
            try await supabase
                .from("daily_goals")
                .update(goal)
                .eq("id", value: goal.id)
                .execute()
            
            if let index = dailyGoals.firstIndex(where: { $0.id == goal.id }) {
                dailyGoals[index] = goal
            }
        } catch {
            errorMessage = "Failed to update daily goal: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadInitialData() {
        Task {
            await loadCategories()
            await loadTimeEntries()
            await loadNotes()
            await loadDailyGoals()
        }
    }
    
    private func getStartDate(for period: TimePeriod) -> Date {
        let now = Date()
        
        switch period.calendarComponent {
        case .hour:
            return Calendar.current.date(byAdding: .hour, value: -period.value, to: now) ?? now
        case .day:
            return now.startOfDay()
        case .weekOfYear:
            return now.startOfWeek()
        case .month:
            return now.startOfMonth()
        case .year:
            return now.startOfYear()
        default:
            return now.startOfDay()
        }
    }
    
    func getTimeSummary(for period: TimePeriod) async -> [TimeSummary] {
        await loadTimeEntries(for: period)
        
        let startDate = getStartDate(for: period)
        let filteredEntries = timeEntries.filter { $0.startTime >= startDate }
        
        let groupedEntries = Dictionary(grouping: filteredEntries) { $0.categoryId }
        
        var summaries: [TimeSummary] = []
        let totalDuration = filteredEntries.reduce(0) { $0 + $1.duration }
        
        for (categoryId, entries) in groupedEntries {
            let category = categories.first { $0.id == categoryId }
            let categoryDuration = entries.reduce(0) { $0 + $1.duration }
            let percentage = totalDuration > 0 ? (categoryDuration / totalDuration) * 100 : 0
            
            summaries.append(TimeSummary(
                categoryId: categoryId,
                categoryName: category?.name ?? "Unknown",
                categoryColor: category?.color ?? "#000000",
                totalDuration: categoryDuration,
                percentage: percentage,
                entryCount: entries.count
            ))
        }
        
        return summaries.sorted { $0.totalDuration > $1.totalDuration }
    }
}

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
