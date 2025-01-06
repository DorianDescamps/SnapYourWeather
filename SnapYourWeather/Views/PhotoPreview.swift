import SwiftUI

struct PhotoPreview: View {
    let image: UIImage
    @Binding var isPresented: Bool

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
                isPresented = false
            }
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
