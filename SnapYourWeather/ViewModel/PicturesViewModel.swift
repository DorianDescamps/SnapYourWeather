import Foundation
import Combine
import SwiftUI

class PicturesViewModel: ObservableObject {
    // Liste des photos récupérées
    @Published var pictures: [Picture] = []
    
    // Pour afficher les messages d'erreur
    @Published var errorMessage: String = ""
    
    // AuthViewModel pour récupérer le token
    private let authViewModel: AuthViewModel
    
    // MARK: - API Endpoints
    enum APIEndpoint: String {
        case fetchPictures = "/pictures"
    }
    
    // MARK: - Initialisation
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    // MARK: - Méthode générique pour les requêtes réseau
    private func performRequest(
        endpoint: APIEndpoint,
        method: String,
        token: String? = nil,
        body: [String: Any]? = nil,
        pathComponent: String? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, String?) -> Void
    ) {
        var endpointURL = EnvironmentConfig.baseURL + endpoint.rawValue
        if let pathComponent = pathComponent {
            endpointURL += "/\(pathComponent)"
        }
        
        guard let url = URL(string: endpointURL) else {
            completion(nil, nil, "URL invalide.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // En-têtes HTTP
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Corps de la requête
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(nil, nil, "Erreur lors de la sérialisation du JSON : \(error.localizedDescription)")
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, nil, "Erreur réseau : \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                completion(data, httpResponse, nil)
            }
        }.resume()
    }
    
    // MARK: - Récupérer la liste des photos
    func fetchPictures(completion: @escaping (Bool, [Picture]?, String?) -> Void) {
        guard let token = authViewModel.authToken else {
            completion(false, nil, "Token introuvable. Veuillez vous reconnecter.")
            return
        }
        
        performRequest(endpoint: .fetchPictures, method: "GET", token: token) { data, response, error in
            if let error = error {
                completion(false, nil, error)
                return
            }
            
            guard let httpResponse = response, let data = data else {
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let datas = jsonObject["datas"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: datas, options: [])
                        let decodedPictures = try JSONDecoder().decode([Picture].self, from: jsonData)
                        completion(true, decodedPictures, nil)
                    } else {
                        completion(false, nil, "Format de réponse inattendu.")
                    }
                } catch {
                    completion(false, nil, "Impossible de parser la réponse JSON : \(error.localizedDescription)")
                }
            default:
                completion(false, nil, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
    
    // MARK: - Récupérer une image spécifique
    func fetchPictureImage(fileName: String, completion: @escaping (Bool, Data?, String?) -> Void) {
        guard let token = authViewModel.authToken else {
            completion(false, nil, "Token introuvable. Veuillez vous reconnecter.")
            return
        }
        
        performRequest(endpoint: .fetchPictures, method: "GET", token: token, pathComponent: fileName) { data, response, error in
            if let error = error {
                completion(false, nil, error)
                return
            }
            
            guard let httpResponse = response, let data = data else {
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(true, data, nil)
            default:
                completion(false, nil, "Erreur inattendue (code \(httpResponse.statusCode)).")
            }
        }
    }
}
