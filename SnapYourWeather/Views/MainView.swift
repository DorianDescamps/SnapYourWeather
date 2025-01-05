//
//  MainView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct MainView: View {
    let token: String
    @State private var selectedTab: Tab = .camera
    @State private var showSettings = false

    enum Tab {
        case camera
        case map
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraEntry()
                .tag(Tab.camera)
            MapView()
                .tag(Tab.map)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

        NavigationBar(selectedTab: $selectedTab)
            .edgesIgnoringSafeArea(.bottom)
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
            .onAppear {
                print("Utilisateur connecté avec le token : \(token)")
            }
    }
}
