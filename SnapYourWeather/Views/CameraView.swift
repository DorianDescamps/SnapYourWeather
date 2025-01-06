import SwiftUI
import AVFoundation
import CoreLocation

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

struct CameraEntry: View {
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
                        .shadow(radius: 10)
                }
                .padding(.bottom, 30)
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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var capturedImage: UIImage?

    var onPhotoCaptured: ((UIImage, Double, Double) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraAccess()
        setupLocationManager()
    }

    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCamera()
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let captureSession = captureSession,
              let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            print("Impossible de configurer la caméra.")
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds

        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }

        captureSession.startRunning()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permission refusée",
            message: "Veuillez activer l'accès à la caméra et à la localisation dans les réglages de l'application.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func capturePhoto() {
        guard currentLocation != nil else {
            print("Localisation non disponible. Essayez à nouveau.")
            showLocationUnavailableAlert()
            return
        }

        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    private func showLocationUnavailableAlert() {
        let alert = UIAlertController(
            title: "Localisation non disponible",
            message: "Nous ne pouvons pas capturer votre position actuelle. Veuillez vérifier vos paramètres de localisation.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func checkIfReadyToCapture() {
        if let image = capturedImage, let location = currentLocation {
            onPhotoCaptured?(image, location.coordinate.latitude, location.coordinate.longitude)
            // Reset after use
            capturedImage = nil
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Erreur lors de la capture de la photo : \(error.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Impossible de récupérer l'image")
            return
        }

        capturedImage = image
        checkIfReadyToCapture()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        checkIfReadyToCapture()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
    }
}
