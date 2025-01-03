//
//  UserRepository.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

class UserRepository {
    static let userKey = "users"
    static let loggedInUserKey = "loggedInUser"

    func saveUser(email: String, password: String, pseudo: String) {
        var users = getUsers()
        let newUser = User(email: email, password: password, pseudo: pseudo)
        users.append(newUser)
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: Self.userKey)
        }
    }

    func getUsers() -> [User] {
        if let data = UserDefaults.standard.data(forKey: Self.userKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            return users
        }
        return []
    }

    func isEmailUsed(_ email: String) -> Bool {
        let users = getUsers()
        return users.contains { $0.email == email }
    }

    func isPseudoUsed(_ pseudo: String) -> Bool {
        let users = getUsers()
        return users.contains { $0.pseudo == pseudo }
    }

    func getUser(email: String) -> User? {
        let users = getUsers()
        return users.first { $0.email == email }
    }

    func loginUser(email: String) {
        UserDefaults.standard.set(email, forKey: Self.loggedInUserKey)
    }

    func getLoggedInUser() -> String? {
        return UserDefaults.standard.string(forKey: Self.loggedInUserKey)
    }

    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: Self.loggedInUserKey)
    }
}
