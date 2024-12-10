//
//  UserSession.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

class UserSession: ObservableObject {
    @Published var loggedInUser: String? = UserManager.getLoggedInUser()

    func login(email: String) {
        UserManager.loginUser(email: email)
        loggedInUser = email
    }

    func logout() {
        UserManager.logoutUser()
        loggedInUser = nil
    }
}
