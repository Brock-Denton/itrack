import SwiftUI

struct NotesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newGoalText = ""
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Daily Goals")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Active goals section
                        ActiveGoalsSection()
                        
                        // Completed goals section
                        CompletedGoalsSection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
        }
    }
}

struct ActiveGoalsSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var activeGoals: [DailyGoal] {
        dataManager.dailyGoals.filter { !$0.isCompleted && $0.date.isToday() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Goals")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(activeGoals.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            if activeGoals.isEmpty {
                EmptyGoalsView(message: "No goals for today")
            } else {
                ForEach(activeGoals.sorted(by: { $0.order < $1.order })) { goal in
                    GoalRowView(goal: goal)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CompletedGoalsSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var completedGoals: [DailyGoal] {
        dataManager.dailyGoals.filter { $0.isCompleted }
            .sorted(by: { $0.completedAt ?? $0.updatedAt > $1.completedAt ?? $1.updatedAt })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Completed Goals")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(completedGoals.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            if completedGoals.isEmpty {
                EmptyGoalsView(message: "No completed goals yet")
            } else {
                ForEach(completedGoals.prefix(10)) { goal in
                    CompletedGoalRowView(goal: goal)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct GoalRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let goal: DailyGoal
    @State private var isEditing = false
    @State private var editedText = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                completeGoal()
            }) {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            // Goal text
            if isEditing {
                TextField("Goal text", text: $editedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        saveGoal()
                    }
            } else {
                Text(goal.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        startEditing()
                    }
            }
            
            Spacer()
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .onAppear {
            editedText = goal.content
        }
    }
    
    private func startEditing() {
        isEditing = true
        editedText = goal.content
    }
    
    private func saveGoal() {
        let updatedGoal = DailyGoal(
            id: goal.id,
            userId: goal.userId,
            content: editedText,
            isCompleted: goal.isCompleted,
            order: goal.order,
            date: goal.date,
            createdAt: goal.createdAt,
            updatedAt: Date(),
            completedAt: goal.completedAt
        )
        
        Task {
            await dataManager.updateDailyGoal(updatedGoal)
            isEditing = false
        }
    }
    
    private func completeGoal() {
        let updatedGoal = DailyGoal(
            id: goal.id,
            userId: goal.userId,
            content: goal.content,
            isCompleted: true,
            order: goal.order,
            date: goal.date,
            createdAt: goal.createdAt,
            updatedAt: Date(),
            completedAt: Date()
        )
        
        Task {
            await dataManager.updateDailyGoal(updatedGoal)
        }
    }
}

struct CompletedGoalRowView: View {
    let goal: DailyGoal
    
    var body: some View {
        HStack(spacing: 12) {
            // Completed checkbox
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
            
            // Goal text
            Text(goal.content)
                .font(.body)
                .foregroundColor(.secondary)
                .strikethrough()
            
            Spacer()
            
            // Completion time
            if let completedAt = goal.completedAt {
                Text(formatCompletionTime(completedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatCompletionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyGoalsView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
}

struct AddGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var goalText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Write Daily Goal Here", text: $goalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(goalText.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        Task {
            await dataManager.createDailyGoal(content: goalText)
            dismiss()
        }
    }
}

#Preview {
    NotesView()
        .environmentObject(DataManager())
}
