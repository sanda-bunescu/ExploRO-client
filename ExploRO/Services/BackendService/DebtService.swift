import Foundation

enum DebtError: Error {
    case invalidURL
    case requestFailed(message: String)
    case decodingError
    case encodingError
    case keyNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let message):
            return "Request failed. Error: \(message)"
        case .decodingError:
            return "Failed to decode response."
        case .encodingError:
            return "Failed to encode request data."
        case .keyNotFound:
            return "Key not found."
        }
    }
}

protocol DebtServiceProtocol {
    func fetchDebts(groupId: Int, idToken: String) async throws -> [DebtDetailResponse]
    func deleteDebt(debtId: Int, idToken: String) async throws
}

class DebtService: DebtServiceProtocol {
    private let baseURL = "http://localhost:3000"
    func fetchDebts(groupId: Int, idToken: String) async throws -> [DebtDetailResponse] {
        guard let url = URL(string: "\(baseURL)/get-user-debts?groupId=\(groupId)") else {
            throw DebtError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw DebtError.requestFailed(message: "Invalid response from server.")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decoded = try decoder.decode([String: [DebtDetailResponse]].self, from: data)
            
            guard let debts = decoded["debts"] else {
                throw DebtError.keyNotFound
            }
            
            return debts
        } catch let decodingError as DecodingError {
            print("Decoding error:", decodingError)
            throw DebtError.decodingError
        } catch {
            print("Unexpected error:", error)
            throw DebtError.requestFailed(message: error.localizedDescription)
        }
    }
    
    func deleteDebt(debtId: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/delete-debt?Id=\(debtId)") else {
            throw DebtError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DebtError.requestFailed(message: "No response from server.")
            }
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    throw DebtError.requestFailed(message: errorMessage)
                } else {
                    throw DebtError.requestFailed(message: "Unknown error occurred.")
                }
            }
            
        } catch {
            print("Error deleting debt:", error)
            throw DebtError.requestFailed(message: error.localizedDescription)
        }
        
    }
    
}
