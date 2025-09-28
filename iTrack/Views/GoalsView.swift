import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var newGoalText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Goals")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Daily objectives")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Add Goal Input
                HStack(spacing: 12) {
                    TextField("Add a goal...", text: $newGoalText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addGoal) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(newGoalText.isEmpty)
                }
                .padding(.horizontal)
                
                // Active Goals
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Goals")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(dataManager.getActiveGoals()) { goal in
                                GoalRow(goal: goal) {
                                    dataManager.toggleGoal(goal)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Completed Goals
                if !dataManager.getCompletedGoals().isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Completed")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(dataManager.getCompletedGoals()) { goal in
                                    CompletedGoalRow(goal: goal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func addGoal() {
        guard !newGoalText.isEmpty else { return }
        dataManager.addGoal(title: newGoalText)
        newGoalText = ""
    }
}

struct GoalRow: View {
    let goal: Goal
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Text(goal.title)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CompletedGoalRow: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            Text(goal.title)
                .font(.body)
                .strikethrough()
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let completedAt = goal.completedAt {
                Text(completedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GoalsView()
        .environmentObject(AppDataManager())
}
