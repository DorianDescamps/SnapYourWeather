import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

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
                    
                    if (errorMessage != nil) {
                        Text(errorMessage!)
                            .foregroundColor(.red)
                    }
                    
                    Button("Se déconnecter") {
                        authViewModel.expireToken() { success, errorMessage in
                            if (success) {
                                authViewModel.unpersistToken()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                print(errorMessage!)
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .padding()
                .navigationTitle("Paramètres")
                .onAppear {
                    authViewModel.fetchUserDetails { success, datas, errorMessage in
                        if (success) {
                            self.email = datas!["email_address"] as! String
                            self.userName = datas!["user_name"] as! String
                        } else {
                            authViewModel.unpersistToken()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}
