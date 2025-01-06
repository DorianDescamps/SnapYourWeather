import SwiftUI

struct PhotoPreview: View {
    @Environment(\.dismiss) private var dismiss
    
    let image: UIImage

    var body: some View {
        VStack (spacing: 30) {
            Text("Prévisualisation de l'image")
                .foregroundColor(.white)
                .padding()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
