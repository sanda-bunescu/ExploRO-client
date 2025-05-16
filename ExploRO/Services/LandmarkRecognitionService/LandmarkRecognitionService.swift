import Foundation
import UIKit

enum LandmarkPredictionError: Error {
    case invalidURL
    case requestFailed
    case noData
    case decodingError
}

protocol LandmarkPredictionServiceProtocol {
    func uploadImage(_ image: UIImage) async throws -> LandmarkPredictionResponse
}

class LandmarkPredictionService: LandmarkPredictionServiceProtocol {
    let baseURL = "http://127.0.0.1:8000"

    func uploadImage(_ image: UIImage) async throws -> LandmarkPredictionResponse {
        guard let url = URL(string: "\(baseURL)/predict"),
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw LandmarkPredictionError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw LandmarkPredictionError.requestFailed
        }

        do {
            let decoded = try JSONDecoder().decode(LandmarkPredictionResponse.self, from: data)
            return decoded
        } catch {
            throw LandmarkPredictionError.decodingError
        }
    }
}
