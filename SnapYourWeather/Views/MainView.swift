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
            CameraView()
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
        .edgesIgnoringSafeArea(.all)
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
