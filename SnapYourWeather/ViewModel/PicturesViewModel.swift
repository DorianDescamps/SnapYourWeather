import Foundation
import Combine
import SwiftUI

class PicturesViewModel: ObservableObject {
    // MARK: - API Endpoints
    enum APIEndpoint: String {
        case fetchPictures = "/pictures"
        case fetchPictureBuffer = "/pictures/"
    }

    // MARK: - Méthode générique pour les requêtes réseau
    private func performRequest(
        method: String,
        endpoint: APIEndpoint,
        pathParameter: String? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        let url = URL(string: EnvironmentConfig.baseURL + endpoint.rawValue + (pathParameter ?? ""))!

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { body, response, error in
            DispatchQueue.main.async {
                completion(body, response as? HTTPURLResponse, error)
            }
        }
        .resume()
    }

    // MARK: - Récupérer les photos
    func fetchPictures(completion: @escaping (Bool, [Picture]?, String?) -> Void) {
        performRequest(method: "GET", endpoint: .fetchPictures) { data, response, error in
            guard error == nil, let response = response else {
                completion(false, nil, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }

            switch response.statusCode {
            case 200:
                let body = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                let datas = body["datas"] as! [[String: Any]]
                let array = try! JSONSerialization.data(withJSONObject: datas, options: [])
                let pictures = try! JSONDecoder().decode([Picture].self, from: array)
                
                completion(true, pictures, nil)
            default:
                completion(false, nil, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }

    // MARK: - Récupérer une image spécifique
    func fetchPictureBuffer(fileName: String, completion: @escaping (Bool, Data?, String?) -> Void) {
        performRequest(method: "GET", endpoint: .fetchPictureBuffer, pathParameter: fileName) { data, response, error in
            guard error == nil, let response = response else {
                completion(false, nil, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }

            switch response.statusCode {
            case 200:
                completion(true, data, nil)
            default:
                completion(false, nil, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
}
