//
//  AlertWrapper.swift
//  SnapYourWeather
//
//  Created by Théo Bontemps on 05/01/2025.
//

import SwiftUI
import UIKit

struct AlertWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let placeholder: String
    let completion: (String?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addTextField { textField in
                textField.placeholder = placeholder
                textField.keyboardType = .asciiCapable
                textField.autocapitalizationType = .none
            }

            let submitAction = UIAlertAction(title: "Valider", style: .default) { _ in
                let input = alert.textFields?.first?.text
                completion(input)
                //isPresented = false
            }

            alert.addAction(submitAction)

            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
