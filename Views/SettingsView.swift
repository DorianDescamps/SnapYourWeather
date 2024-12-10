//
//  SettingsView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userSession: UserSession
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Se déconnecter") {
                    userSession.logout()
                    navigationPath.removeLast(navigationPath.count)
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Paramètres")
        }
    }
}
