import SwiftUI

struct LoginView: View {
    @ObservedObject var userManager: UserManager
    @State private var newUsername = ""
    @State private var showingCreateUser = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("iTrack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Time Tracking & Goal Completion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !userManager.existingUsers.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select User")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(userManager.existingUsers) { user in
                                    Button(action: {
                                        userManager.selectUser(user: user)
                                    }) {
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundColor(.blue)
                                            VStack(alignment: .leading) {
                                                Text(user.username)
                                                    .font(.body)
                                                Text("Last active: \(user.lastActiveAt, style: .relative)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                Button(action: {
                    showingCreateUser = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New User")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingCreateUser) {
            CreateUserView(userManager: userManager, isPresented: $showingCreateUser)
        }
    }
}

struct CreateUserView: View {
    @ObservedObject var userManager: UserManager
    @Binding var isPresented: Bool
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Text("Create New User")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Enter username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    if !username.isEmpty {
                        userManager.createUser(username: username)
                        isPresented = false
                    }
                }) {
                    Text("Create User")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(username.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(username.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
        }
    }
}
