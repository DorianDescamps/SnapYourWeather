import Foundation
import AVFoundation
import Combine
import SwiftUI

class PicturesViewModel: ObservableObject {
    // MARK: - API Endpoints
    enum APIEndpoint: String {
        case pictures = "/pictures"
    }
    
    // MARK: - Méthode générique pour les requêtes réseau
    private func performRequest(
        method: String,
        endpoint: APIEndpoint,
        pathParameter: String? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        let URL_ = URL(string: EnvironmentConfig.baseURL + endpoint.rawValue + (pathParameter ?? ""))!
        
        var request = URLRequest(url: URL_)
        request.httpMethod = method
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let token = UserRepository.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            DispatchQueue.main.async {
                completion(body, response as? HTTPURLResponse, error)
            }
        }
        .resume()
    }
    
    // MARK: - Récupérer les photos
    func getPictures(completion: @escaping (Bool, [Picture]?, String?) -> Void) {
        let headers = ["Content-Type": "application/json"]
        
        performRequest(method: "GET", endpoint: .pictures, headers: headers) { data, response, error in
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
            case 401:
                completion(false, nil, "Token invalide.")
            case 403:
                completion(false, nil, "Token expiré.")
            default:
                completion(false, nil, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
    
    // MARK: - Envoyer une photo
    func uploadPicture(picture: UIImage, latitude: Double, longitude: Double, completion: @escaping (Bool, String?) -> Void) {
        let boundary = UUID().uuidString
        
        let headers = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"picture\"; filename=\"picture.heic\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/heic\r\n\r\n".data(using: .utf8)!)
        body.append(picture.heicData()!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(latitude)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(longitude)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        performRequest(method: "PUT", endpoint: .pictures, headers: headers, body: body) { _, response, error in
            guard error == nil, let response = response else {
                completion(false, "Impossible d'obtenir une réponse valide du serveur.")
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(true, nil)
            case 401:
                completion(false, "Token invalide.")
            case 403:
                completion(false, "Token expiré.")
            case 415:
                completion(false, "Format de fichier non pris en charge.")
            case 422:
                completion(false, "Nom d'utilisateur non défini.")
            default:
                completion(false, "Erreur inattendue (code \(response.statusCode)).")
            }
        }
    }
}
