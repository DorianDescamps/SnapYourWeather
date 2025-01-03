//
//  MainView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct MainView: View {
    let email: String
    @State private var showSettings = false

    var body: some View {
        TabView {
            ZStack {
                CameraView()
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.9)
                    .background(Color.black)
                    .cornerRadius(10)

                if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
                    Text("Caméra indisponible dans le simulateur")
                        .foregroundColor(.white)
                }
            }
            .tabItem {
                Label("Caméra", systemImage: "camera")
            }

            VStack {
                Text("Coucou")
                    .font(.largeTitle)
                Text("Utilisateur : \(email)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .tabItem {
                Label("Message", systemImage: "message")
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
    }
}
