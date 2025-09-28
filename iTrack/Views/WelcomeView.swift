import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var userName = ""
    @State private var showingNameInput = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 20) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("iTrack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Simple Time Tracking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                showingNameInput = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .sheet(isPresented: $showingNameInput) {
            NameInputView()
        }
    }
}

struct NameInputView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var userName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("What's your name?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    TextField("Enter your name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button(action: {
                    if !userName.isEmpty {
                        dataManager.createUser(name: userName)
                        dismiss()
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(userName.isEmpty)
                .padding(.horizontal, 40)
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppDataManager())
}
