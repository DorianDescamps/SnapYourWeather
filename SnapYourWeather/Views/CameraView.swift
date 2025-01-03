//
//  CameraView.swift
//  SnapYourWeather
//
//  Created by etudiant on 10/12/2024.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Pas besoin de mise à jour pour cette vue
    }
}

class CameraViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraAccess()
    }

    /// Demande l'accès à la caméra et configure la caméra si l'utilisateur donne son autorisation.
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

    /// Configure la caméra et la prévisualisation.
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

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds

        if let videoPreviewLayer = videoPreviewLayer {
            view.layer.addSublayer(videoPreviewLayer)
        }

        captureSession.startRunning()
    }

    /// Affiche une alerte si l'utilisateur refuse l'accès à la caméra.
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permission refusée",
            message: "Veuillez activer l'accès à la caméra dans les réglages de l'application.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
    }
}
