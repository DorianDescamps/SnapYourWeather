//
//  SignupView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Étapes du flow
    enum SignupStep {
        case emailCheck
        case requestCode
        case setPassword
        case finished
    }
    
    @State private var currentStep: SignupStep = .emailCheck
    
    @State private var email = ""
    @State private var temporaryCode = ""
    @State private var password = ""
    
    @State private var showLoginAfterSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case .emailCheck:
                Text("Étape 1 : Votre email")
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Vérifier l'email") {
                    authViewModel.checkEmailAvailability(email: email) { success in
                        if success {
                            currentStep = .requestCode
                        }
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                
            case .requestCode:
                Text("Étape 2 : Envoyer le code temporaire")
                Text("Un code de 6 chiffres vous sera envoyé par mail.")
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Demander le code") {
                    authViewModel.requestTemporaryCode(email: email) { success in
                        if success {
                            currentStep = .setPassword
                        }
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                
            /*case .codeValidation:
                Text("Étape 3 : Saisir le code reçu par mail")
                TextField("Code à 6 chiffres", text: $temporaryCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Valider le code") {
                    // Ici vous pouvez juste changer d'étape, la validation réelle se fera avec le password
                    if temporaryCode.count == 6 {
                        currentStep = .setPassword
                    } else {
                        authViewModel.errorMessage = "Le code doit contenir 6 chiffres."
                    }
                }
                .buttonStyle(SecondaryButtonStyle())*/
                
            case .setPassword:
                Text("Étape 3 : Saisir le code reçu par mail et choisir un mot de passe")
                TextField("Code à 6 chiffres", text: $temporaryCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                }
    
                SecureField("Mot de passe (8 caractères min.)", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Créer le compte") {
                    authViewModel.setPassword(email: email, temporaryCode: temporaryCode, password: password) { success in
                        if success {
                            currentStep = .finished
                            showLoginAfterSuccess = true
                        }
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                
            case .finished:
                Text("Compte créé avec succès. Vous pouvez vous connecter.")
                NavigationLink(value: "Login") {
                    Text("Se connecter")
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding()
        .navigationTitle("Inscription")
    }
}
