import SwiftUI
import RealityKit
import ARKit
import UIKit

extension Notification.Name {
    static let captureARImage = Notification.Name("captureARImage")
    static let predictionResult = Notification.Name("predictionResult")
}

struct ARCameraView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        arView.session.run(config)

        context.coordinator.setup(arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        private var arView: ARView?

        func setup(_ arView: ARView) {
            self.arView = arView
            NotificationCenter.default.addObserver(self, selector: #selector(captureCurrentImage), name: .captureARImage, object: nil)
        }

        @objc func captureCurrentImage() {
            guard let pixelBuffer = arView?.session.currentFrame?.capturedImage else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = UIImage(ciImage: ciImage)

            Task {
                do {
                    let prediction = try await YourPredictionService.shared.predict(from: uiImage)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .predictionResult, object: nil, userInfo: [
                            "label": prediction.label,
                            "lat": prediction.lat ?? 0.0,
                            "lon": prediction.lon ?? 0.0
                        ])
                    }
                } catch {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .predictionResult, object: nil, userInfo: ["label": "Prediction failed"])
                    }
                }
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
