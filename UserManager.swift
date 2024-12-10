//
//  UserManager.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

struct User: Codable {
    let email: String
    let password: String
    let pseudo: String
}

class UserManager {
    static let userKey = "users"
    static let loggedInUserKey = "loggedInUser"

    static func saveUser(email: String, password: String, pseudo: String) {
        var users = getUsers()
        let newUser = User(email: email, password: password, pseudo: pseudo)
        users.append(newUser)
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    static func getUsers() -> [User] {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            return users
        }
        return []
    }

    static func isEmailUsed(_ email: String) -> Bool {
        let users = getUsers()
        return users.contains { $0.email == email }
    }

    static func isPseudoUsed(_ pseudo: String) -> Bool {
        let users = getUsers()
        return users.contains { $0.pseudo == pseudo }
    }

    static func getUser(email: String) -> User? {
        let users = getUsers()
        return users.first { $0.email == email }
    }

    static func loginUser(email: String) {
        UserDefaults.standard.set(email, forKey: loggedInUserKey)
    }

    static func getLoggedInUser() -> String? {
        return UserDefaults.standard.string(forKey: loggedInUserKey)
    }

    static func logoutUser() {
        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
    }
}
