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
    
    @State private var mainImageData: Data? = nil
    @State private var iconImageData: Data? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                HStack {
                    Text(picture.weatherDetails.city)
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            if let data = iconImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            } else {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                            
                            Text("\(Int(round(Double(picture.weatherDetails.feltTemperature) ?? 0)))°C")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.secondary)
                        }
                        
                        Text(picture.weatherDetails.description.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.horizontal, .top])
                
                Divider()
                    .background(Color.gray.opacity(0.4))
                
                if let data = mainImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 500)
                        .cornerRadius(10)
                        .padding()
                } else {
                    ProgressView("Chargement de la photo...")
                        .frame(maxHeight: 500)
                        .padding()
                }
                
                VStack(spacing: 5) {
                    Text("@\(picture.user.user_name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(picture.datetime))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Fermer") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .navigationTitle("Détails de la photo")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let iconURL = URL(string: picture.weatherDetails.large_icon_url) {
                    URLSession.shared.dataTask(with: iconURL) { data, _, _ in
                        DispatchQueue.main.async {
                            self.iconImageData = data
                        }
                    }.resume()
                }
                
                picturesVM.fetchPictureImage(fileName: picture.fileName) { data in
                    self.mainImageData = data
                }
            }
        }
    }
    
    private func formatDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: isoDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return outputFormatter.string(from: date)
        } else {
            return "Date invalide"
        }
    }
}
