import SwiftUI
import UIKit

struct UserNameAlert: UIViewControllerRepresentable {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            presentAlert(
                on: uiViewController,
                message: "Il doit contenir uniquement des lettres, chiffres et underscore.",
                isError: false
            )
        }
    }

    private func presentAlert(on viewController: UIViewController, message: String, isError: Bool) {
        let alert = UIAlertController(title: "Un pseud0 ?", message: nil, preferredStyle: .alert)

        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [
                .foregroundColor: isError ? UIColor.red : UIColor.black,
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

            authViewModel.setUserDetails(userName: input) { success, errorMessage in
                DispatchQueue.main.async {
                    if success {
                        isPresented = false
                    } else {
                        presentAlert(
                            on: viewController,
                            message: errorMessage ?? "Une erreur est survenue.",
                            isError: true
                        )
                    }
                }
            }
        }

        alert.addAction(submitAction)

        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
