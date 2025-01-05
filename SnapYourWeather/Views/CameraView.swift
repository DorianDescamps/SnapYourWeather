import SwiftUI
import AVFoundation

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

struct CameraEntry: View {
    @State private var cameraController: CameraViewController?
    @State private var capturedImage: UIImage? = nil
    @State private var showPreview = false

    var body: some View {
        ZStack {
            CameraViewControllerRepresentable { controller in
                self.cameraController = controller
                controller.onPhotoCaptured = { image in
                    self.capturedImage = image
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
        .sheet(isPresented: $showPreview) {
            if let image = capturedImage {
                PhotoPreview(image: image, isPresented: $showPreview)
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

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?

    var onPhotoCaptured: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraAccess()
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

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permission refusée",
            message: "Veuillez activer l'accès à la caméra dans les réglages de l'application.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func capturePhoto() {
        print("Capture de la photo...")
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
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

        // Utilise le callback pour transmettre l'image
        onPhotoCaptured?(image)
        print("Photo capturée et transmise à SwiftUI.")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
    }
}
