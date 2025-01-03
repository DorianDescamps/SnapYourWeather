//
//  NavigationBar.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI

struct NavigationBar: View {
    @Binding var selectedTab: MainView.Tab

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                if selectedTab != .camera {
                    withAnimation {
                        selectedTab = .camera
                    }
                }
            }) {
                VStack {
                    Image(systemName: "camera")
                        .font(.system(size: 24))
                    Text("Caméra")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(selectedTab == .camera ? .blue : .gray)

            Button(action: {
                if selectedTab != .map {
                    withAnimation {
                        selectedTab = .map
                    }
                }
            }) {
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 24))
                    Text("Carte")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(selectedTab == .map ? .blue : .gray)

            Spacer()
        }
        .frame(height: 60)
        .background(Color.white)
    }
}
