import Foundation
import AVFoundation

class CameraControlManager: ObservableObject {
    @Published var scrollValue: Int = 0
    private let captureSession = AVCaptureSession()

    func setupControl() {
        guard captureSession.supportsControls else { return }

        captureSession.beginConfiguration()

        let slider = AVCaptureSlider(
            "Valeur",
            symbolName: "slider.vertical.3",
            in: 0...100
        )

        slider.setActionQueue(.main) { [weak self] newValue in
            self?.scrollValue = Int(newValue)
        }

        if captureSession.canAddControl(slider) {
            captureSession.addControl(slider)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
}
