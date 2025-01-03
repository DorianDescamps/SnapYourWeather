//
//  SignupView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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
            
                // Minuscules seulement
                .autocapitalization(.none)

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text(errorMessage)
                .foregroundColor(.red)

            Button("S'inscrire") {
                if let error = authViewModel.signup(email: email, password: password, pseudo: pseudo) {
                    errorMessage = error
                } else {
                    errorMessage = "Inscription réussie !"
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .navigationTitle("Inscription")
    }
}
