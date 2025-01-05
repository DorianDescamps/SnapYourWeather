import Foundation
import SwiftUI
import Combine

class PicturesViewModel: ObservableObject {
    
    @Published var pictures: [Picture] = []
    @Published var errorMessage: String = ""
    
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func fetchPictures() {
        guard let token = authViewModel.authToken else {
            self.errorMessage = "Token introuvable, veuillez vous reconnecter."
            return
        }
        
        guard let url = URL(string: EnvironmentConfig.baseURL + "/pictures") else {
            self.errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    self.errorMessage = "Réponse serveur invalide."
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    self.errorMessage = "Erreur inattendue (code \(httpResponse.statusCode))."
                    return
                }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let datas = jsonObject["datas"] as? [[String: Any]] {
                        // Convertir JSON en tableau de Picture
                        let jsonData = try JSONSerialization.data(withJSONObject: datas, options: [])
                        let decodedPictures = try JSONDecoder().decode([Picture].self, from: jsonData)
                        self.pictures = decodedPictures
                    } else {
                        self.errorMessage = "Format de réponse inattendu."
                    }
                } catch {
                    self.errorMessage = "Impossible de parser la réponse JSON : \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchPictureImage(fileName: String, completion: @escaping (Data?) -> Void) {
        guard let token = authViewModel.authToken else {
            self.errorMessage = "Token introuvable, veuillez vous reconnecter."
            completion(nil)
            return
        }
        
        guard let url = URL(string: EnvironmentConfig.baseURL + "/pictures/\(fileName)") else {
            self.errorMessage = "URL invalide pour la photo."
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau pour l'image : \(error.localizedDescription)"
                    completion(nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data,
                      httpResponse.statusCode == 200 else {
                    self.errorMessage = "Impossible de récupérer l'image (code ou réponse invalide)."
                    completion(nil)
                    return
                }
                
                completion(data)
            }
        }.resume()
    }
}
