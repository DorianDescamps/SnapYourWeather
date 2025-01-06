import SwiftUI

struct EntryView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if TokenManager.shared.tokenExists() {
                MainView()
            } else {
                VStack(spacing: 30) {
                    Button("Connexion") {
                        navigationPath.append("Login")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Inscription") {
                        navigationPath.append("SignUp")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .navigationTitle("Bienvenue")
                .navigationDestination(for: String.self) { destination in
                    if destination == "Login" {
                        SignInView(navigationPath: $navigationPath)
                    } else if destination == "SignUp" {
                        SignUpView()
                    }
                }
                .padding()
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
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
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(configuration.isPressed ? .blue.opacity(0.7) : .blue)
            .cornerRadius(10)
    }
}
