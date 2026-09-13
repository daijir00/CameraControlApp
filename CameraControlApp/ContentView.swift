import SwiftUI
import AVFoundation

class PreviewUIView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

struct ContentView: View {
    @StateObject private var cameraManager = CameraControlManager()

    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.captureSession)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // Header status
                Text(cameraManager.supportsControlsStatus)
                    .font(.caption)
                    .bold()
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 50)

                Spacer()

                // Display hardware values
                VStack(spacing: 8) {
                    Text(String(format: "Zoom : %.1f", cameraManager.sliderValue))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.yellow)

                    Text(String(format: "Exposition : %.2f", cameraManager.exposureValue))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)

                // Real-time Event Log Console
                VStack(alignment: .leading, spacing: 4) {
                    Text("📋 Console d'événements Matériels :")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(cameraManager.logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(height: 120)
                }
                .padding(10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}
