import SwiftUI
import UIKit

struct UserNameAlert: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            presentAlert(on: uiViewController, message: "Il doit contenir uniquement des lettres, chiffres et underscore.")
        }
    }

    private func presentAlert(on viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "Un pseud0 ?", message: nil, preferredStyle: .alert)

        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [
                .foregroundColor: message.contains("invalide") ? UIColor.red : UIColor.black,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        alert.addTextField { textField in
            textField.placeholder = "ton_pseudo"
            textField.keyboardType = .asciiCapable
            textField.autocapitalizationType = .none
        }

        let submitAction = UIAlertAction(title: "Valider", style: .default) { _ in
            guard let input = alert.textFields?.first?.text else { return }

            if isValidUsername(input) {
                isPresented = false
            } else {
                presentAlert(
                    on: viewController,
                    message: "Nom d'utilisateur invalide. Utilisez uniquement des lettres, chiffres et underscores."
                )
            }
        }

        alert.addAction(submitAction)

        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    private func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9_]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return predicate.evaluate(with: username)
    }
}
