import Foundation
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var existingUsers: [User] = []
    
    private let userDefaultsKey = "iTrackUsers"
    private let currentUserDefaultsKey = "iTrackCurrentUser"

    init() {
        loadUsers()
        loadCurrentUser()
    }

    func createUser(username: String) {
        let newUser = User(username: username, createdAt: Date(), lastActiveAt: Date(), timezone: TimeZone.current.identifier)
        existingUsers.append(newUser)
        currentUser = newUser
        saveUsers()
        saveCurrentUser()
    }

    func selectUser(user: User) {
        currentUser = user
        currentUser?.lastActiveAt = Date()
        saveCurrentUser()
        saveUsers()
    }

    func deleteUser(user: User) {
        existingUsers.removeAll { $0.id == user.id }
        if currentUser?.id == user.id {
            currentUser = nil
        }
        saveUsers()
        saveCurrentUser()
    }

    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: data) {
            self.existingUsers = decodedUsers
        }
    }

    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(existingUsers) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserDefaultsKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = decodedUser
        }
    }

    private func saveCurrentUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: currentUserDefaultsKey)
        }
    }
}
