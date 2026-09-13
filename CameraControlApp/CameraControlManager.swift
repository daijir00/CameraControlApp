import Foundation
import AVFoundation

class CameraControlManager: NSObject, ObservableObject {
    @Published var sliderValue: Float = 0.0
    
    let captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        captureSession.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        self.captureDevice = device
        
        // Configuration de la commande du slider Camera Control (iOS 18+)
        if #available(iOS 18.0, *) {
            let slider = AVCaptureSlider("Zoom", symbolName: "magnifyingglass", valueRange: 0...100)
            slider.setActionQueue(DispatchQueue.main) { [weak self] value in
                self?.sliderValue = value
            }
            
            if captureSession.supportsControls {
                captureSession.addControl(slider)
            }
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
}
