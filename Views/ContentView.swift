//
//  ContentView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

import SwiftUI

struct ContentView: View {
    @StateObject private var userSession = UserSession()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if let user = userSession.loggedInUser {
                WelcomeView(email: user, userSession: userSession, navigationPath: $navigationPath)
            } else {
                VStack(spacing: 20) {
                    Button("Connexion") {
                        navigationPath.append("Login")
                    }
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Inscription") {
                        navigationPath.append("Signup")
                    }
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .navigationTitle("Bienvenue")
                .navigationDestination(for: String.self) { destination in
                    if destination == "Login" {
                        LoginView(userSession: userSession, navigationPath: $navigationPath)
                    } else if destination == "Signup" {
                        SignupView()
                    }
                }
            }
        }
        .onAppear {
            userSession.loggedInUser = UserManager.getLoggedInUser()
        }
    }
}
