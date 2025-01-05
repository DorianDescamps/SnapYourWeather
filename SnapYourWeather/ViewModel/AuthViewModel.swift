import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    // Informations pour la session
    @Published var authToken: String? = nil
    
    // Pour afficher les messages d'erreur
    @Published var errorMessage: String = ""
    
    // Gestion des données locales (token)
    private let userRepository: UserRepository
    
    // MARK: - API Endpoints
    enum APIEndpoint: String {
        case checkEmail = "/account/create"
        case requestTemporaryCode = "/account/security/temporary-code"
        case setPassword = "/account/security/password"
        case login = "/account/security/token"
        case userDetails = "/account"
    }
    
    // MARK: - Initialisation
    init(userRepository: UserRepository = UserRepository()) {
        self.userRepository = userRepository
        self.authToken = userRepository.getSavedToken()
    }
    
    // MARK: - Méthode générique pour les requêtes réseau
    private func performRequest(
        endpoint: APIEndpoint,
        method: String,
        token: String? = nil,
        body: [String: Any]? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        guard let url = URL(string: EnvironmentConfig.baseURL + endpoint.rawValue) else {
            self.errorMessage = "URL invalide."
            completion(nil, nil, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // En-têtes HTTP
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(data, response as? HTTPURLResponse, error)
            }
        }.resume()
    }
    
    // MARK: - Vérifier si l'email est disponible
    func checkEmailAvailability(email: String, completion: @escaping (Bool) -> Void) {
        let body = ["email_address": email]
        performRequest(endpoint: .checkEmail, method: "POST", body: body) { _, response, error in
            if let error = error {
                self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                completion(false)
                return
            }
            guard let httpResponse = response else {
                self.errorMessage = "Réponse invalide du serveur."
                completion(false)
                return
            }
            switch httpResponse.statusCode {
            case 200:
                completion(true)
            case 409:
                self.errorMessage = "Cet email est déjà utilisé."
                completion(false)
            default:
                self.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))."
                completion(false)
            }
        }
    }
    
    // MARK: - Demander un code temporaire
    func requestTemporaryCode(email: String, completion: @escaping (Bool) -> Void) {
        let body = ["email_address": email]
        performRequest(endpoint: .requestTemporaryCode, method: "POST", body: body) { _, response, error in
            if let error = error {
                self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                completion(false)
                return
            }
            guard let httpResponse = response else {
                self.errorMessage = "Réponse invalide du serveur."
                completion(false)
                return
            }
            completion(httpResponse.statusCode == 200)
        }
    }
    
    // MARK: - Définir le mot de passe
    func setPassword(email: String, temporaryCode: String, password: String, completion: @escaping (Bool) -> Void) {
        let body = [
            "email_address": email,
            "temporary_code": temporaryCode,
            "password": password
        ]
        performRequest(endpoint: .setPassword, method: "POST", body: body) { _, response, error in
            if let error = error {
                self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                completion(false)
                return
            }
            guard let httpResponse = response else {
                self.errorMessage = "Réponse invalide du serveur."
                completion(false)
                return
            }
            switch httpResponse.statusCode {
            case 200:
                completion(true)
            case 403:
                self.errorMessage = "Code temporaire invalide."
                completion(false)
            case 400:
                self.errorMessage = "Mot de passe non conforme (8 caractères minimum)."
                completion(false)
            default:
                self.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))."
                completion(false)
            }
        }
    }
    
    // MARK: - Connexion
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let body = [
            "email_address": email,
            "password": password
        ]
        performRequest(endpoint: .login, method: "POST", body: body) { data, response, error in
            if let error = error {
                self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                completion(false)
                return
            }
            guard let httpResponse = response, let data = data else {
                self.errorMessage = "Réponse invalide du serveur."
                completion(false)
                return
            }
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let datas = jsonObject["datas"] as? [String: Any],
                       let token = datas["value"] as? String {
                        self.authToken = token
                        self.userRepository.saveToken(token)
                        completion(true)
                    } else {
                        self.errorMessage = "Format de réponse inattendu."
                        completion(false)
                    }
                } catch {
                    self.errorMessage = "Impossible de parser la réponse JSON."
                    completion(false)
                }
            case 403:
                self.errorMessage = "Mot de passe invalide."
                completion(false)
            case 401:
                self.errorMessage = "Email invalide."
                completion(false)
            default:
                self.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))."
                completion(false)
            }
        }
    }
    
    // MARK: - Récupérer les détails de l'utilisateur connecté
    func fetchUserDetails(completion: @escaping (Bool, [String: Any]?, String?) -> Void) {
        guard let token = self.authToken else {
            completion(false, nil, "Token introuvable. Veuillez vous reconnecter.")
            return
        }

        performRequest(endpoint: .userDetails, method: "GET", token: token) { data, response, error in
            if let error = error {
                completion(false, nil, "Erreur réseau : \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response, let data = data else {
                completion(false, nil, "Réponse serveur invalide.")
                return
            }

            switch httpResponse.statusCode {
                case 200:
                    let body = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let datas = body["datas"] as! [String: Any]
                    completion(true, datas, nil)
                default:
                    completion(false, nil, "Erreur inattendue (code \(httpResponse.statusCode)).")
                }
        }
    }

    // MARK: - Modifier les détails de l'utilisateur connecté
    func setUserDetails(userName: String, completion: @escaping (Bool, String?) -> Void) {
        guard let token = self.authToken else {
            completion(false, "Token introuvable, veuillez vous reconnecter.")
            return
        }

        let body = ["user_name": userName]
        performRequest(endpoint: .userDetails, method: "POST", token: token, body: body) { _, response, error in
            if let error = error {
                completion(false, "Erreur réseau : \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response else {
                completion(false, "Réponse serveur invalide.")
                return
            }

            switch httpResponse.statusCode {
                case 200:
                    completion(true, nil)
                case 400:
                    completion(false, "Nom d'utilisateur invalide. Utilisez uniquement des lettres, chiffres et underscores.")
                case 409:
                    completion(false, "Nom d'utilisateur déjà utilisé.")
                default:
                    completion(false, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }

    // MARK: - Déconnexion
    func logout() {
        self.authToken = nil
        userRepository.removeToken()
    }
}
