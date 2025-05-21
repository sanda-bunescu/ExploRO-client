import UIKit

class YourPredictionService {
    static let shared = YourPredictionService()
    
    func predict(from image: UIImage) async throws -> LandmarkPredictionResponse {
        return try await LandmarkPredictionService().uploadImage(image)
    }
}
