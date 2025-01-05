//
//  UserRepository.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

class UserRepository {
    static let tokenKey = "authToken"

    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: Self.tokenKey)
    }
    
    func getSavedToken() -> String? {
        UserDefaults.standard.string(forKey: Self.tokenKey)
    }
    
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: Self.tokenKey)
    }
}
