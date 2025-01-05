import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var navigationPath: NavigationPath
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 30) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if (errorMessage != nil) {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }

            Button("Se connecter") {
                authViewModel.getToken(email: email, password: password) { success, datas, errorMessage in
                    if (success) {
                        navigationPath.removeLast(navigationPath.count)
                    } else {
                        self.errorMessage = errorMessage
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Connexion")
    }
}
