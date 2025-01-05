import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email: String = ""
    @State private var userName: String = ""

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
                }
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("Se déconnecter") {
                    authViewModel.logout()
                    presentationMode.wrappedValue.dismiss()
                }
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
                .padding()
                .navigationTitle("Paramètres")
                .onAppear {
                    authViewModel.fetchUserDetails { success, datas, errorMessage in
                        if (success) {
                            self.email = datas!["email_address"] as! String
                            self.userName = datas!["user_name"] as! String
                        } else {
                            authViewModel.logout()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}
