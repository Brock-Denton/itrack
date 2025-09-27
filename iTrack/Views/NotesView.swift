import SwiftUI

struct NotesView: View {
    @StateObject private var dataManager = DataManager()
    @StateObject private var userManager = UserManager()
    @State private var newGoalText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Daily Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Goals")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(getActiveGoals()) { goal in
                                HStack {
                                    Button(action: {
                                        toggleGoal(goal)
                                    }) {
                                        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(goal.isCompleted ? .green : .gray)
                                            .font(.title2)
                                    }
                                    
                                    Text(goal.title)
                                        .strikethrough(goal.isCompleted)
                                        .foregroundColor(goal.isCompleted ? .secondary : .primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                    
                    HStack {
                        TextField("Write Daily Goal Here", text: $newGoalText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addGoal) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(newGoalText.isEmpty)
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completed Goals")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(getCompletedGoals()) { goal in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    
                                    Text(goal.title)
                                        .foregroundColor(.secondary)
                                        .strikethrough(true)
                                    
                                    Spacer()
                                    
                                    if let completedAt = goal.completedAt {
                                        Text(completedAt, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()
            }
        }
    }
    
    private func getActiveGoals() -> [Goal] {
        return dataManager.getGoals(for: userManager.currentUser?.id ?? UUID(), completed: false)
    }
    
    private func getCompletedGoals() -> [Goal] {
        return dataManager.getCompletedGoals(for: userManager.currentUser?.id ?? UUID(), within: 24)
    }
    
    private func addGoal() {
        guard !newGoalText.isEmpty else { return }
        
        let newGoal = Goal(
            title: newGoalText,
            userId: userManager.currentUser?.id ?? UUID(),
            goalDate: Date(),
            isCompleted: false,
            completedAt: nil,
            order: getActiveGoals().count,
            createdAt: Date()
        )
        
        dataManager.addGoal(newGoal)
        newGoalText = ""
    }
    
    private func toggleGoal(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        updatedGoal.completedAt = updatedGoal.isCompleted ? Date() : nil
        
        dataManager.updateGoal(updatedGoal)
    }
}
