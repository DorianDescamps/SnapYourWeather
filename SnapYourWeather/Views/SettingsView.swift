//
//  SettingsView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email: String = ""
    @State private var userName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Affichage des informations utilisateur
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email : \(email)")
                        .font(.headline)
                    Text("Pseudo : \(userName)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                // Bouton de déconnexion
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
                authViewModel.fetchUserDetails { _, _ in
                    self.email = authViewModel.loggedInUserEmail ?? "Non défini"
                    self.userName = authViewModel.userName ?? "Non défini"
                    print("Détails utilisateur : Email - \(self.email), Pseudo - \(self.userName)")
                }
            }
        }
    }
}
