//
//  MainView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct MainView: View {
    let email: String
    @EnvironmentObject var authViewModel: AuthViewModel
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
            SettingsView()
        }
        .navigationBarBackButtonHidden(true)
    }
}
