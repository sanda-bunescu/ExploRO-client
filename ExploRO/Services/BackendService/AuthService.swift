import Foundation

enum BackendServiceError: Error, LocalizedError {
    case backendError(ErrorResponse)
    case unknownError
    case badURL
    case unexpectedStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .backendError(let errorResponse):
            return errorResponse.error
        case .badURL:
            return "Invalid URL."
        case .unexpectedStatusCode(let statusCode):
            return "Unexpected status code: \(statusCode)"
        case .unknownError:
            return "Unknown error occurred."
        }
    }
}

enum BackendAction{
    case createUser
    case loginUser
    case deleteUser
}

protocol AuthServiceProtocol {
    func sendIdTokenToBackend(idToken: String, for action: BackendAction) async throws -> UserResponse
}

class AuthService: AuthServiceProtocol {
    func sendIdTokenToBackend(idToken: String, for action: BackendAction) async throws -> UserResponse {
        //print(idToken)
        let baseURL = AppConfig.baseURL
        var urlString: String
        switch action {
        case .createUser:
            urlString = "\(baseURL)/create-user"
        case .loginUser:
            urlString = "\(baseURL)/login-user"
        case .deleteUser:
            urlString = "\(baseURL)/delete-user"
        }

        guard let url = URL(string: urlString) else {
            throw BackendServiceError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let httpResponse = response as? HTTPURLResponse else {
                throw BackendServiceError.unknownError
            }

            if httpResponse.statusCode == 200 {
                let userResponse = try decoder.decode(UserResponse.self, from: data)
                return userResponse
            } else {
                if let backendError = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw BackendServiceError.backendError(backendError)
                } else {
                    throw BackendServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
            }
        } catch {
            throw error
        }
    }

}

