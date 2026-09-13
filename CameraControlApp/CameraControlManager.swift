import Foundation
import AVFoundation

class CameraControlManager: NSObject, ObservableObject {
    @Published var sliderValue: Float = 0.0
    @Published var exposureValue: Float = 0.0
    @Published var logs: [String] = []
    @Published var supportsControlsStatus: String = "Vérification..."
    
    let captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?

    override init() {
        super.init()
        log("Initialisation de CameraControlManager")
        setupSession()
    }

    func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let entry = "[\(timestamp)] \(message)"
        DispatchQueue.main.async {
            self.logs.insert(entry, at: 0)
            if self.logs.count > 20 {
                self.logs.removeLast()
            }
        }
    }

    private func setupSession() {
        captureSession.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            log("❌ Échec entrée caméra")
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            log("✅ Entrée caméra ajoutée")
        }
        
        self.captureDevice = device
        
        // Configuration des commandes Camera Control (iOS 18+)
        if #available(iOS 18.0, *) {
            if captureSession.supportsControls {
                DispatchQueue.main.async {
                    self.supportsControlsStatus = "✅ supportsControls = TRUE"
                }
                log("✅ supportsControls est TRUE")
                
                // 1. Slider Zoom (0.0 ... 100.0)
                let zoomSlider = AVCaptureSlider("Zoom", symbolName: "magnifyingglass", valueRange: 0.0...100.0)
                zoomSlider.setActionQueue(DispatchQueue.main) { [weak self] value in
                    self?.sliderValue = value
                    self?.log("🎛️ Zoom Event : \(String(format: "%.2f", value))")
                }
                if captureSession.canAddControl(zoomSlider) {
                    captureSession.addControl(zoomSlider)
                    log("✅ Control Zoom Slider ajouté")
                }

                // 2. Slider Exposition (-2.0 ... 2.0)
                let expSlider = AVCaptureSlider("Exposition", symbolName: "sun.max", valueRange: -2.0...2.0)
                expSlider.setActionQueue(DispatchQueue.main) { [weak self] value in
                    self?.exposureValue = value
                    self?.log("☀️ Exposure Event : \(String(format: "%.2f", value))")
                }
                if captureSession.canAddControl(expSlider) {
                    captureSession.addControl(expSlider)
                    log("✅ Control Exposure Slider ajouté")
                }
            } else {
                DispatchQueue.main.async {
                    self.supportsControlsStatus = "❌ supportsControls = FALSE"
                }
                log("❌ supportsControls = FALSE")
            }
        } else {
            DispatchQueue.main.async {
                self.supportsControlsStatus = "❌ iOS 18+ requis"
            }
            log("❌ Version iOS < 18")
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            self?.log("▶️ AVCaptureSession.startRunning()")
        }
    }
}
