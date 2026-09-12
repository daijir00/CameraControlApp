import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var manager = CameraControlManager()
    @State private var cameraStatus: String = "Demande d'autorisation..."

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Camera Control App")
                .font(.title)
                .bold()

            Text("Valeur du bouton")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(manager.scrollValue)")
                .font(.system(size: 80, weight: .bold))

            Text(cameraStatus)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            requestCameraPermission()
        }
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.cameraStatus = "Accès Caméra : Autorisé"
                    self.manager.setupControl()
                } else {
                    self.cameraStatus = "Accès Caméra : Refusé"
                }
            }
        }
    }
}
