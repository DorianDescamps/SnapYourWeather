import SwiftUI

struct PicturePreviewView: View {
    @StateObject private var picturesViewModel = PicturesViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    private var picture: UIImage
    private var latitude: Double
    private var longitude: Double
    @State private var error: String? = nil
    
    init(picture: UIImage, latitude: Double, longitude: Double) {
        self.picture = picture
        self.latitude = latitude
        self.longitude = longitude
    }

    var body: some View {
        VStack (alignment: .leading, spacing: 30) {
            Image(uiImage: picture)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button("Envoyer") {
                picturesViewModel.uploadPicture(picture: picture, latitude: latitude, longitude: longitude) { success, error in
                    if success {
                        dismiss()
                    } else {
                        self.error = error
                    }
                }
            }
                .buttonStyle(PrimaryButtonStyle())

            Spacer()
            
            Button("Fermer") {
                dismiss()
            }
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
