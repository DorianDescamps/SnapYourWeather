import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var authToken: String? = nil
    
    private let userRepository: UserRepository
    
    // MARK: - API Endpoints
    enum APIEndpoint: String {
        case createAccount = "/account/create"
        case requestTemporaryCode = "/account/security/temporary-code"
        case setPassword = "/account/security/password"
        case getToken = "/account/security/token"
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
            completion(nil, nil, URLError(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            DispatchQueue.main.async {
                completion(body, response as? HTTPURLResponse, error)
            }
        }
        .resume()
    }
    
    // MARK: - Créer un compte
    func createAccount(email: String, completion: @escaping (Bool, String?) -> Void) {
        let body = ["email_address": email]
        
        performRequest(endpoint: .createAccount, method: "POST", body: body) { _, response, error in
            if let error = error {
                completion(false, "Erreur réseau : \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response else {
                completion(false, "Réponse invalide du serveur.")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(true, nil)
            case 400:
                completion(false, "Adresse e-mail invalide.")
            case 409:
                completion(false, "Adresse e-mail déjà utilisé.")
            default:
                completion(false, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    // MARK: - Demander un code temporaire
    func requestTemporaryCode(email: String, completion: @escaping (Bool, [String: Any]?, String?) -> Void) {
        let body = ["email_address": email]
        
        performRequest(endpoint: .requestTemporaryCode, method: "POST", body: body) { _, response, error in
            if let error = error {
                completion(false, nil, "Erreur réseau : \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response else {
                completion(false, nil, "Réponse invalide du serveur.")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(true, nil, nil)
            case 400:
                completion(false, nil, "Adresse e-mail invalide.")
            case 401:
                completion(false, nil, "Adresse e-mail invalide.")
            default:
                completion(false, nil, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    // MARK: - Définir le mot de passe
    func setPassword(email: String, temporaryCode: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let body = [
            "email_address": email,
            "temporary_code": temporaryCode,
            "password": password
        ]
        
        performRequest(endpoint: .setPassword, method: "POST", body: body) { _, response, error in
            if let error = error {
                completion(false, "Erreur réseau : \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response else {
                completion(false, "Réponse invalide du serveur.")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(true, nil)
            case 400:
                completion(false, "Code temporaire ou mot de passe invalide (8 caractères minimum).")
            case 401:
                completion(false, "Adresse e-mail invalide.")
            case 403:
                completion(false, "Code temporaire invalide.")
            default:
                completion(false, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    // MARK: - Obtenir un jeton d'authentification
    func getToken(email: String, password: String, completion: @escaping (Bool, [String: Any]?, String?) -> Void) {
        let body = [
            "email_address": email,
            "password": password
        ]
        
        performRequest(endpoint: .getToken, method: "POST", body: body) { data, response, error in
            if let error = error {
                completion(false, nil, "Erreur réseau : \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response, let data = data else {
                completion(false, nil, "Réponse invalide du serveur.")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                let body = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let datas = body["datas"] as! [String: Any]
                
                completion(true, datas, nil)
            case 400:
                completion(false, nil, "Adresse e-mail ou mot de passe invalide.")
            case 401:
                completion(false, nil, "Adresse e-mail invalide.")
            case 403:
                completion(false, nil, "Mot de passe invalide.")
            default:
                completion(false, nil, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    func expireToken(completion: @escaping (Bool, String?) -> Void) {
        performRequest(endpoint: .userDetails, method: "DELETE") { _, response, error in
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
            case 401:
                completion(false, "Token invalide.")
            case 403:
                completion(false, "Token expiré.")
            default:
                completion(false, "Erreur inattendue (code \(httpResponse.statusCode)).")
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
                case 401:
                    completion(false, nil, "Token invalide.")
                case 403:
                    completion(false, nil, "Token expiré.")
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
                case 401:
                    completion(false, "Token invalide.")
                case 403:
                    completion(false, "Token expiré.")
                case 409:
                    completion(false, "Nom d'utilisateur déjà utilisé.")
                default:
                    completion(false, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    // MARK: - Sauvegarde du jeton d'authentification
    func persistToken(token: String) {
        self.authToken = token
        userRepository.saveToken(token)
    }

    // MARK: - Suppression du jeton d'authentification
    func unpersistToken() {
        userRepository.removeToken()
        self.authToken = nil
    }
}
