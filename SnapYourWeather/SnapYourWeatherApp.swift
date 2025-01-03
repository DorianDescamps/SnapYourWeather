//
//  SnapYourWeatherApp.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI
import SwiftData

@main
struct SnapYourWeatherApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            EntryView()
                .environmentObject(authViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
