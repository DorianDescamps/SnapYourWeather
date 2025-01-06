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
        }
        .navigationTitle("Inscription")
    }
    
    @ViewBuilder
    private func setViewStep(for step: SignupStep) -> some View {
        switch step {
        case .createAccount:
            CreateAccountStepView(email: $email, errorMessage: $errorMessage) {
                authViewModel.createAccount(email: email) { success, errorMessage in
                    if (success) {
                        currentStep = .requestTemporaryCode
                    } else {
                        self.errorMessage = errorMessage
                    }
                }
            }
            
        case .requestTemporaryCode:
            RequestTemporaryCodeView (errorMessage: $errorMessage) {
                authViewModel.requestTemporaryCode(email: email) { success, errorMessage in
                    if (success) {
                        currentStep = .setPassword
                    }
                }
            }
            
        case .setPassword:
            SetPasswordStepView(email: $email, temporaryCode: $temporaryCode, password: $password, errorMessage: $errorMessage) {
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
    @Binding var errorMessage: String?
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Adresse e-mail")
                    .font(.headline)
                
                TextField("prenom.nom@u-picardie.fr", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if (errorMessage != nil) {
                    Text(errorMessage!)
                        .foregroundColor(.red)
                }
                
                Button("Créer le compte", action: onNext)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
    }
}

struct RequestTemporaryCodeView: View {
    @Binding var errorMessage: String?
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Code temporaire par e-mail")
                .font(.headline)
            
            if (errorMessage != nil) {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }
            
            Button("Recevoir le code temporaire par e-mail", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}

struct SetPasswordStepView: View {
    @Binding var email: String
    @Binding var temporaryCode: String
    @Binding var password: String
    @Binding var errorMessage: String?
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Code temporaire reçu par e-mail")
                    .font(.headline)
                
                TextField("XXXXXX", text: $temporaryCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
    
            VStack(alignment: .leading, spacing: 15) {
                Text("Mot de passe (8 caractères minimum)")
                    .font(.headline)
                
                SecureField("TonSuperMotDePasse_", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if (errorMessage != nil) {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }
            
            Button("Définir le mot de passe", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}

struct FinishedStepView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Compte créé avec succès !")
                .font(.headline)
            
            NavigationLink(value: "Login") {
                Text("Se connecter")
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
    }
}
