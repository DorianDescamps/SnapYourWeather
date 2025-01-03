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

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
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
        }
    }
}
