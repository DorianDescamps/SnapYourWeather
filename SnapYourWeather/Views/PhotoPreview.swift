import SwiftUI

struct PhotoPreview: View {
    let image: UIImage
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Prévisualisation de l'image")
                .foregroundColor(.white)
                .padding()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button("Fermer") {
                isPresented = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            print("PhotoPreview - Image reçue : \(image)")
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
