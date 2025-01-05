//
//  PictureDetailView.swift
//  SnapYourWeather
//
//  Created by etudiant on 05/01/2025.
//

import SwiftUI

struct PictureDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var picturesVM: PicturesViewModel
    
    let picture: Picture
    
    @State private var mainImageData: Data? = nil  // pour la photo du /pictures/{{fileName}}
    @State private var iconImageData: Data? = nil   // pour l'icône large_icon_url
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Photo principale
                if let data = mainImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    ProgressView("Chargement de la photo...")
                        .frame(height: 200)
                }
                
                // Icône météo
                if let data = iconImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } else {
                    ProgressView("Chargement de l'icône...")
                        .frame(width: 100, height: 100)
                }
                
                // Infos texte
                Text("Ville : \(picture.weatherDetails.city)")
                Text("Description : \(picture.weatherDetails.description)")
                Text("Température ressentie : \(picture.weatherDetails.feltTemperature)°C")
                Text("Publié par : \(picture.user.user_name)")
                Text("Date : \(picture.dateFormatted)")
                
                Spacer()
                
                // Bouton de fermeture
                Button("Fermer") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            .navigationTitle("Détails de la photo")
            .onAppear {
                // Récupérer la grande icône météo
                if let iconURL = URL(string: picture.weatherDetails.large_icon_url) {
                    URLSession.shared.dataTask(with: iconURL) { data, _, _ in
                        DispatchQueue.main.async {
                            self.iconImageData = data
                        }
                    }.resume()
                }
                
                // Récupérer la photo sur /pictures/{{fileName}}
                picturesVM.fetchPictureImage(fileName: picture.fileName) { data in
                    self.mainImageData = data
                }
            }
        }
    }
}
