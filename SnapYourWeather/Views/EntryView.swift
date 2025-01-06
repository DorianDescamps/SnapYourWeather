import SwiftUI

struct EntryView: View {
    @State private var navigationPath = NavigationPath()
    @State private var shouldRefresh = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if UserRepository.tokenExists() {
                MainView(navigationPath: $navigationPath, shouldRefresh: $shouldRefresh)
            } else {
                VStack(spacing: 30) {
                    Button("Connexion") {
                        navigationPath.append("SignInView")
                    }
                        .buttonStyle(PrimaryButtonStyle())

                    Button("Inscription") {
                        navigationPath.append("SignUpView")
                    }
                        .buttonStyle(SecondaryButtonStyle())
                }
                .navigationTitle("Bienvenue")
                .navigationDestination(for: String.self) { destination in
                    if destination == "SignInView" {
                        SignInView(navigationPath: $navigationPath, shouldRefresh: $shouldRefresh)
                    } else if destination == "SignUpView" {
                        SignUpView()
                    }
                }
                .padding()
            }
        }
        .onChange(of: shouldRefresh) { _, newValue in
            if newValue {
                shouldRefresh = false
                navigationPath = NavigationPath()
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? .blue.opacity(0.7) : .blue)
            .cornerRadius(10)
    }
}
