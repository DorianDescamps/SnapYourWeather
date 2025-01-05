import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    enum SignupStep {
        case createAccount
        case requestTemporaryCode
        case setPassword
        case finished
    }
    
    @State private var currentStep: SignupStep = .createAccount
    @State private var email = ""
    @State private var temporaryCode = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil
    @State private var showLoginAfterSuccess = false
    
    var body: some View {
        VStack(spacing: 30) {
            setViewStep(for: currentStep)
            
            if (errorMessage != nil) {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Inscription")
    }
    
    @ViewBuilder
    private func setViewStep(for step: SignupStep) -> some View {
        switch step {
        case .createAccount:
            CreateAccountStepView(email: $email) {
                authViewModel.createAccount(email: email) { success, errorMessage in
                    if (success) {
                        currentStep = .requestTemporaryCode
                    } else {
                        self.errorMessage = errorMessage
                    }
                }
            }
            
        case .requestTemporaryCode:
            RequestTemporaryCodeView {
                authViewModel.requestTemporaryCode(email: email) { success, datas, errorMessage in
                    if (success) {
                        currentStep = .setPassword
                    }
                }
            }
            
        case .setPassword:
            SetPasswordStepView(email: $email, temporaryCode: $temporaryCode, password: $password) {
                authViewModel.setPassword(email: email, temporaryCode: temporaryCode, password: password) { success, errorMessage in
                    if (success) {
                        currentStep = .finished
                        showLoginAfterSuccess = true
                    }
                }
            }
            
        case .finished:
            FinishedStepView()
        }
    }
}

struct CreateAccountStepView: View {
    @Binding var email: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Étape 1 : Votre email")
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button("Vérifier l'email", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct RequestTemporaryCodeView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Étape 2 : Envoyer le code temporaire")
            Text("Un code de 6 chiffres vous sera envoyé par mail.")
            
            Button("Demander le code", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct SetPasswordStepView: View {
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
                .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct FinishedStepView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Compte créé avec succès. Vous pouvez vous connecter.")
            
            NavigationLink(value: "Login") {
                Text("Se connecter")
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}
