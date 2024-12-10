//
//  WelcomeView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation

import SwiftUI

struct WelcomeView: View {
    let email: String
    @ObservedObject var userSession: UserSession
    @Binding var navigationPath: NavigationPath

    @State private var showSettings = false

    var body: some View {
        VStack {
            Text("Bienvenue, \(email)!")
                .font(.largeTitle)
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(userSession: userSession, navigationPath: $navigationPath)
        }
        .navigationBarBackButtonHidden(true)
    }
}
