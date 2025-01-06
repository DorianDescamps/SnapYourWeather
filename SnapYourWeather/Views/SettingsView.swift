import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var navigationPath: NavigationPath
    @Binding var shouldRefresh: Bool
    
    @State private var email: String = ""
    @State private var userName: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Adresse e-mail")
                            .font(.headline)
                        Text(email)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Nom d'utilisateur")
                            .font(.headline)
                        Text(userName)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button("Se déconnecter") {
                        authViewModel.expireToken { success, error in
                            if success {
                                UserRepository.unpersistToken()
                                shouldRefresh = true
                                presentationMode.wrappedValue.dismiss()
                            } else if let error = error {
                                self.errorMessage = error
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()

                Button("Fermer") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .navigationTitle("Paramètres")
            .padding()
            .onAppear {
                authViewModel.fetchUserDetails { success, datas, error in
                    if success {
                        self.email = datas!["email_address"] as! String
                        self.userName = datas!["user_name"] as! String
                    } else {
                        UserRepository.unpersistToken()
                        shouldRefresh = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
