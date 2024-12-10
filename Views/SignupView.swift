//
//  SignupView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation
import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var pseudo = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Pseudo", text: $pseudo)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(errorMessage)
                .foregroundColor(.red)
            Button("S'inscrire") {
                let normalizedEmail = email.lowercased()
                
                // Vérification du pseudo
                guard pseudo.count >= 4 else {
                    errorMessage = "Le pseudo doit contenir au moins 4 caractères."
                    return
                }
                
                guard isValidEmail(normalizedEmail) else {
                    errorMessage = "Veuillez entrer une adresse email valide."
                    return
                }
                
                guard password.count >= 6 else {
                    errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
                    return
                }
                
                if UserManager.isEmailUsed(normalizedEmail) {
                    errorMessage = "Cet email est déjà utilisé."
                    return
                }
                
                if UserManager.isPseudoUsed(pseudo) {
                    errorMessage = "Ce pseudo est déjà utilisé."
                    return
                }
                
                UserManager.saveUser(email: normalizedEmail, password: password, pseudo: pseudo)
                errorMessage = "Inscription réussie !"
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("Inscription")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[0-9a-z._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
