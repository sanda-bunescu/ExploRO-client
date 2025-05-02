import Foundation

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
        print(idToken)
        var urlString: String
        switch action {
        case .createUser:
            urlString = "http://localhost:3000/create-user"
        case .loginUser:
            urlString = "http://localhost:3000/login-user"
        case .deleteUser:
            urlString = "http://localhost:3000/delete-user"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do{
            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            let userResponse = try decoder.decode(UserResponse.self, from: data)
            return userResponse
        }catch{
            print("Error decoding backend user response: \(error)")
            throw error
        }
    }
}

