import SwiftUI

struct SignUpView: View {
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
        VStack(spacing: 30) {
            // Affiche les vues spécifiques à chaque étape
            stepView(for: currentStep)
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Inscription")
    }
    
    @ViewBuilder
    private func stepView(for step: SignupStep) -> some View {
        switch step {
        case .emailCheck:
            StepEmailCheckView(email: $email) {
                authViewModel.checkEmailAvailability(email: email) { success in
                    if success {
                        currentStep = .requestCode
                    }
                }
            }
            
        case .requestCode:
            StepRequestCodeView {
                authViewModel.requestTemporaryCode(email: email) { success in
                    if success {
                        currentStep = .setPassword
                    }
                }
            }
            
        case .setPassword:
            StepSetPasswordView(email: $email, temporaryCode: $temporaryCode, password: $password) {
                authViewModel.setPassword(email: email, temporaryCode: temporaryCode, password: password) { success in
                    if success {
                        currentStep = .finished
                        showLoginAfterSuccess = true
                    }
                }
            }
            
        case .finished:
            StepFinishedView()
        }
    }
}

struct StepEmailCheckView: View {
    @Binding var email: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Étape 1 : Votre email")
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button("Vérifier l'email", action: onNext)
                .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct StepRequestCodeView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Étape 2 : Envoyer le code temporaire")
            Text("Un code de 6 chiffres vous sera envoyé par mail.")
            
            Button("Demander le code", action: onNext)
                .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct StepSetPasswordView: View {
    @Binding var email: String
    @Binding var temporaryCode: String
    @Binding var password: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Étape 3 : Saisir le code reçu par mail et choisir un mot de passe")
            
            TextField("Code à 6 chiffres", text: $temporaryCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            SecureField("Mot de passe (8 caractères min.)", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Créer le compte", action: onNext)
                .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct StepFinishedView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Compte créé avec succès. Vous pouvez vous connecter.")
            
            NavigationLink(value: "Login") {
                Text("Se connecter")
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}
