import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var navigationPath: NavigationPath
    @Binding var shouldRefresh: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Email")
                    .font(.headline)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            VStack(alignment: .leading, spacing: 15) {
                Text("Mot de passe")
                    .font(.headline)
                
                SecureField("Mot de passe", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if (errorMessage != nil) {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }

            Button("Se connecter") {
                authViewModel.getToken(email: email, password: password) { success, errorMessage in
                    if (success) {
                        shouldRefresh = true
                        navigationPath.removeLast(navigationPath.count)
                    } else {
                        self.errorMessage = errorMessage
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .navigationTitle("Connexion")
        .padding()
    }
}
