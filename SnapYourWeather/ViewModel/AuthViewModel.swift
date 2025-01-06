import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
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
    }
    
    // MARK: - Méthode générique pour les requêtes réseau
    private func performRequest(
        method: String,
        endpoint: APIEndpoint,
        body: [String: Any]? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        let url = URL(string: EnvironmentConfig.baseURL + endpoint.rawValue)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
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
        
        performRequest(method: "POST", endpoint: .createAccount, body: body) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(true, nil)
            case 400:
                completion(false, "Adresse e-mail invalide.")
            case 409:
                completion(false, "Adresse e-mail déjà utilisée.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
    
    // MARK: - Demander un code temporaire
    func requestTemporaryCode(email: String, completion: @escaping (Bool, String?) -> Void) {
        let body = ["email_address": email]
        
        performRequest(method: "POST", endpoint: .requestTemporaryCode, body: body) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(true, nil)
            case 400:
                completion(false, "Adresse e-mail invalide.")
            case 401:
                completion(false, "Adresse e-mail inconnue.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
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
        
        performRequest(method: "POST", endpoint: .setPassword, body: body) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(true, nil)
            case 400:
                completion(false, "Code temporaire ou mot de passe invalide.")
            case 401:
                completion(false, "Adresse e-mail inconnue.")
            case 403:
                completion(false, "Code temporaire invalide.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
    
    // MARK: - Obtenir un jeton d'authentification
    func getToken(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let body = [
            "email_address": email,
            "password": password
        ]
        
        performRequest(method: "POST", endpoint: .getToken, body: body) { data, response, error in
            guard error == nil, let response = response, let data = data else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                let body = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let datas = body["datas"] as! [String: Any]
                let token = datas["value"] as! String
                
                TokenManager.shared.persistToken(token: token)
                
                completion(true, nil)
            case 400:
                completion(false, "Adresse e-mail ou mot de passe invalide.")
            case 401:
                completion(false, "Adresse e-mail inconnue.")
            case 403:
                completion(false, "Mot de passe invalide.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
    
    // MARK: - Supprimer le token
    func expireToken(completion: @escaping (Bool, String?) -> Void) {
        performRequest(method: "DELETE", endpoint: .getToken) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                TokenManager.shared.unpersistToken()
                
                completion(true, nil)
            case 401:
                completion(false, "Token invalide.")
            case 403:
                completion(false, "Token expiré.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
    
    // MARK: - Récupérer les détails de l'utilisateur connecté
    func fetchUserDetails(completion: @escaping (Bool, [String: Any]?, String?) -> Void) {
        performRequest(method: "GET", endpoint: .userDetails) { data, response, error in
            guard error == nil, let response = response else {
                completion(false, nil, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }

            switch response.statusCode {
                case 200:
                    let body = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    let datas = body["datas"] as! [String: Any]
                    
                    completion(true, datas, nil)
                case 401:
                    completion(false, nil, "Token invalide.")
                case 403:
                    completion(false, nil, "Token expiré.")
                default:
                    completion(false, nil, "Erreur inattendue (code \(response.statusCode)).")
                }
            }
        }

    // MARK: - Modifier les détails de l'utilisateur connecté
    func setUserDetails(userName: String, completion: @escaping (Bool, String?) -> Void) {
        let body = ["user_name": userName]
            
        performRequest(method: "POST", endpoint: .userDetails, body: body) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }

            switch response.statusCode {
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
                    completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
}
