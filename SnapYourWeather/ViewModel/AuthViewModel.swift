//
//  AuthViewModel.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    
    // Informations pour la session
    @Published var loggedInUserEmail: String? = nil
    @Published var userName: String? = nil
    @Published var authToken: String? = nil
    
    // Pour afficher les messages d'erreur
    @Published var errorMessage: String = ""
    
    // Pour la gestion des données locales (token)
    private let userRepository: UserRepository
    
    // MARK: - Initialisation
    init(userRepository: UserRepository = UserRepository()) {
        self.userRepository = userRepository
        // Récupération éventuelle du token déjà stocké (session persistée)
        self.authToken = userRepository.getSavedToken()
    }
    
    // MARK: - Vérifier si l'email est disponible (Étape 1 de l'inscription)
    // POST /account/create
    //
    // Retourne code 409 si l'email existe déjà, 200 sinon
    //
    func checkEmailAvailability(email: String, completion: @escaping (Bool) -> Void) {
        let urlString = EnvironmentConfig.baseURL + "/account/create"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "email_address": email
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur."
                    completion(false)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // L'email n'est pas utilisé, on peut passer à l'étape suivante
                    completion(true)
                case 409:
                    // L'email est déjà utilisé
                    self.errorMessage = "Cet email est déjà utilisé."
                    completion(false)
                default:
                    self.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Demander un code temporaire (Étape 2)
    // POST /account/security/temporary-code
    //
    // Envoi un code 6 chiffres par email
    //
    func requestTemporaryCode(email: String, completion: @escaping (Bool) -> Void) {
        let urlString = EnvironmentConfig.baseURL + "/account/security/temporary-code"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "email_address": email
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur."
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    // Code envoyé
                    completion(true)
                } else {
                    self.errorMessage = "Impossible d'envoyer le code temporaire (code \(httpResponse.statusCode))."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Définir le mot de passe avec le code temporaire (Étape 3)
    // POST /account/security/password
    //
    // Besoin du temporary_code reçu par email, plus le nouveau password
    //
    func setPassword(email: String, temporaryCode: String, password: String, completion: @escaping (Bool) -> Void) {
        let urlString = EnvironmentConfig.baseURL + "/account/security/password"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "email_address": email,
            "temporary_code": temporaryCode,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur."
                    completion(false)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // Mot de passe défini, compte créé
                    completion(true)
                case 403:
                    // temporary_code invalide
                    self.errorMessage = "Code temporaire invalide."
                    completion(false)
                case 400:
                    // Mdp non conforme (ex: moins de 8 caractères)
                    self.errorMessage = "Mot de passe non conforme (8 caractères minimum)."
                    completion(false)
                default:
                    self.errorMessage = "Erreur (code \(httpResponse.statusCode))."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Connexion (login)
    // POST /account/security/token
    //
    // Retourne un token si l'email/password sont corrects
    //
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let urlString = EnvironmentConfig.baseURL + "/account/security/token"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "email_address": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.errorMessage = "Réponse invalide du serveur."
                    completion(false)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let success = jsonObject["success"] as? Bool, success == true,
                           let datas = jsonObject["datas"] as? [String: Any],
                           let tokenValue = datas["value"] as? String {
                            
                            // On récupère le token
                            self.authToken = tokenValue
                            self.loggedInUserEmail = email
                            // Sauvegarde du token en local
                            self.userRepository.saveToken(tokenValue)
                            
                            print("Login réussi, token récupéré.")
                            print("Utilisateur connecté avec le token : \(tokenValue)")
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
                    // Mdp invalide
                    self.errorMessage = "Mot de passe invalide."
                    completion(false)
                case 401:
                    // Email invalide
                    self.errorMessage = "Email invalide."
                    completion(false)
                default:
                    self.errorMessage = "Erreur (code \(httpResponse.statusCode))."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Récupérer les détails de l'utilisateur connecté
    // GET /account
    //
    // On vérifie si user_name est null => l'utilisateur doit définir un pseudo
    func fetchUserDetails(completion: @escaping (Bool, Bool) -> Void) {
        guard let token = self.authToken else {
            self.errorMessage = "Token introuvable, veuillez vous reconnecter."
            completion(false, false)
            return
        }

        let urlString = EnvironmentConfig.baseURL + "/account"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false, false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false, false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.errorMessage = "Réponse serveur invalide."
                    completion(false, false)
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Réponse serveur : \(jsonString)")
                }

                switch httpResponse.statusCode {
                case 200:
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let success = jsonObject["success"] as? Bool, success == true,
                           let datas = jsonObject["datas"] as? [String: Any] {
                            
                            let email = datas["email_address"] as? String
                            let userName = datas["user_name"] as? String
                            
                            // Mise à jour des propriétés
                            self.loggedInUserEmail = email
                            self.userName = userName
                            
                            let needsUsername = (userName == nil)
                            completion(true, needsUsername)
                        } else {
                            self.errorMessage = "Format de réponse inattendu."
                            completion(false, false)
                        }
                    } catch {
                        self.errorMessage = "Impossible de parser la réponse JSON : \(error.localizedDescription)"
                        completion(false, false)
                    }
                    
                default:
                    self.errorMessage = "Erreur (code \(httpResponse.statusCode))."
                    completion(false, false)
                }
            }
        }.resume()
    }
    
    // MARK: - Définir le pseudo après la connexion
    // POST /account
    //

    func setUsername(userName: String, completion: @escaping (Bool) -> Void) {
        guard let token = self.authToken else {
            self.errorMessage = "Token introuvable, veuillez vous reconnecter."
            completion(false)
            return
        }
        
        let urlString = EnvironmentConfig.baseURL + "/account"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Authentification par Bearer token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_name": userName
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur."
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("Pseudo défini avec succès.")
                    completion(true)
                } else {
                    self.errorMessage = "Impossible de définir le pseudo (code \(httpResponse.statusCode))."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Déconnexion
    func logout() {
        self.authToken = nil
        self.loggedInUserEmail = nil
        self.errorMessage = ""
        userRepository.removeToken()
    }
}
