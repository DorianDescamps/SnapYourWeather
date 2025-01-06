import UIKit
import AVFoundation
import CoreLocation

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
        startOrientationNotifications()
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
    
    private func startOrientationNotifications() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func orientationDidChange() {
        guard let connection = videoPreviewLayer?.connection, connection.isVideoOrientationSupported else { return }

        var phoneOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            phoneOrientation = .landscapeRight
        case .landscapeRight:
            phoneOrientation = .landscapeLeft
        case .portraitUpsideDown:
            phoneOrientation = .portraitUpsideDown
        default:
            phoneOrientation = .portrait
        }

        connection.videoOrientation = phoneOrientation
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
