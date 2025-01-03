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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreviewLayer?.frame = view.layer.bounds
    }
}

struct CameraScreen: View {
    var body: some View {
        ZStack {
            CameraView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)

            if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
                Text("Caméra indisponible dans le simulateur")
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitle("Caméra", displayMode: .inline)
    }
}
