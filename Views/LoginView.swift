//
//  LoginView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @ObservedObject var userSession: UserSession
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(errorMessage)
                .foregroundColor(.red)
            Button("Se connecter") {
                let normalizedEmail = email.lowercased()

                guard isValidEmail(normalizedEmail) else {
                    errorMessage = "Veuillez entrer une adresse email valide."
                    return
                }

                if let user = UserManager.getUser(email: normalizedEmail), user.password == password {
                    userSession.login(email: normalizedEmail)
                    navigationPath.removeLast(navigationPath.count)
                } else {
                    errorMessage = "Identifiants incorrects."
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("Connexion")
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[0-9a-z._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
