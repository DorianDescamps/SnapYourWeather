//
//  HomeView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct EntryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if let token = authViewModel.authToken, !token.isEmpty {
                MainView(token: token)
            } else {
                VStack(spacing: 20) {
                    Button("Connexion") {
                        navigationPath.append("Login")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Inscription") {
                        navigationPath.append("Signup")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding()
                .navigationTitle("Bienvenue")
                .navigationDestination(for: String.self) { destination in
                    if destination == "Login" {
                        LoginView(navigationPath: $navigationPath)
                    } else if destination == "Signup" {
                        SignupView()
                    }
                }
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.green.opacity(0.7) : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
