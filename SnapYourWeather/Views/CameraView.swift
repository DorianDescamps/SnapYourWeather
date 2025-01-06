import SwiftUI
import AVFoundation
import CoreLocation

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

struct CameraView: View {
    @State private var cameraController: CameraViewController?
    @State private var picture: UIImage? = nil
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var showPreview = false
    
    var body: some View {
        ZStack {
            CameraViewControllerRepresentable { controller in
                self.cameraController = controller
                
                controller.onPhotoCaptured = { image, latitude, longitude in
                    self.picture = image
                    self.latitude = latitude
                    self.longitude = longitude
                    
                    self.showPreview = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            
            VStack {
                Spacer()
                
                Button(action: {
                    cameraController?.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                }
                .padding()
            }
            
            if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
                Text("Caméra indisponible dans le simulateur")
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: Binding(
            get: { showPreview },
            set: { showPreview = $0 }
        )) {
            if let picture = picture,
               let latitude = latitude,
               let longitude = longitude {
                PicturePreviewView(picture: picture, latitude: latitude, longitude: longitude)
            }
        }
        .navigationBarTitle("Caméra", displayMode: .inline)
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    let onControllerReady: (CameraViewController) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        onControllerReady(controller)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
