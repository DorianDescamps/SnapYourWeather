//
//  AuthViewModel.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var loggedInUserEmail: String? = nil
    private let userRepository: UserRepository

    init(userRepository: UserRepository = UserRepository()) {
        self.userRepository = userRepository
        self.loggedInUserEmail = userRepository.getLoggedInUser()
    }

    func login(email: String, password: String) -> String? {
        let normalizedEmail = email.lowercased()
        guard isValidEmail(normalizedEmail) else {
            return "Veuillez entrer une adresse email valide."
        }
        guard let user = userRepository.getUser(email: normalizedEmail), user.password == password else {
            return "Identifiants incorrects."
        }
        userRepository.loginUser(email: normalizedEmail)
        loggedInUserEmail = normalizedEmail
        return nil
    }

    func signup(email: String, password: String, pseudo: String) -> String? {
        let normalizedEmail = email.lowercased()
        
        guard pseudo.count >= 1 && pseudo.count <= 50 else {
            return "Le pseudo doit contenir au moins 4 caractères."
        }
        
        guard email.count <= 320 else {
            return "L'email ne doit pas dépasser 320 caractères."
        }
        
        guard isValidEmail(normalizedEmail) else {
            return "Veuillez entrer une adresse email valide."
        }
        
        guard password.count >= 8 else {
            return "Le mot de passe doit contenir au moins 6 caractères."
        }
        
        guard !userRepository.isEmailUsed(normalizedEmail) else {
            return "Cet email est déjà utilisé."
        }
        
        guard !userRepository.isPseudoUsed(pseudo) else {
            return "Ce pseudo est déjà utilisé."
        }
        
        userRepository.saveUser(email: normalizedEmail, password: password, pseudo: pseudo)
        return nil
    }

    func logout() {
        userRepository.logoutUser()
        loggedInUserEmail = nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[0-9a-z._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
