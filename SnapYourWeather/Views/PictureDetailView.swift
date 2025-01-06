import SwiftUI

struct PictureDetailView: View {
    @StateObject private var picturesViewModel = PicturesViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var pictureBufferEndpoint = "/pictures/"
    
    @State public var picture: Picture
    @State private var weatherIconURL: URL?
    @State private var pictureURL: URL?
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text(picture.weatherDetails.city)
                    .font(.title)
                    .bold()
                    
                Spacer()
                    
                VStack(alignment: .trailing) {
                    HStack {
                        AsyncImage(url: weatherIconURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            case .failure:
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            @unknown default:
                                EmptyView()
                            }
                        }
                            
                        Text("\(Int(round(Double(picture.weatherDetails.feltTemperature)!)))°C")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.secondary)
                    }
                        
                    Text(picture.weatherDetails.description)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
                
            Divider()
                .background(Color.gray.opacity(0.3))
                
            AsyncImage(url: pictureURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 500)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 500)
                case .failure:
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 500)
                @unknown default:
                    EmptyView()
                }
            }
                
            VStack(spacing: 15) {
                Text("@\(picture.user.user_name)")
                    .foregroundColor(.secondary)
                    
                Text(formatDate(picture.datetime))
                    .foregroundColor(.secondary)
            }
                
            Spacer()

            Button("Fermer") {
                dismiss()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.weatherIconURL = URL(string: picture.weatherDetails.large_icon_url)
            self.pictureURL = URL(string: EnvironmentConfig.baseURL + pictureBufferEndpoint + picture.fileName)
        }
    }
    
    private func formatDate(_ isoDate: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = inputFormatter.date(from: isoDate)!
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return outputFormatter.string(from: date)
    }
}
