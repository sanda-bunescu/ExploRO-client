import SwiftUI
import UIKit

@MainActor
class LandmarkPredictionViewModel: ObservableObject {
    @Published var prediction: LandmarkPredictionResponse?
    @Published var errorMessage: String?
    
    private let predictionService: LandmarkPredictionServiceProtocol

    init(predictionService: LandmarkPredictionServiceProtocol = LandmarkPredictionService()) {
        self.predictionService = predictionService
    }

    func uploadImage(_ image: UIImage) async {
        do {
            let result = try await predictionService.uploadImage(image)
            self.prediction = result
            self.errorMessage = nil
        } catch {
            self.prediction = nil
            self.errorMessage = "Upload failed: \(error)"
        }
    }
}
