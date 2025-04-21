import Foundation

enum ExpenseError: Error {
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
    case keyNotFound
}

protocol ExpenseServiceProtocol {
    func fetchExpenses(forGroup groupId: Int, idToken: String) async throws -> [ExpenseResponse]
}

class ExpenseService: ExpenseServiceProtocol {
    private let baseURL = "http://localhost:3000"
    
    func fetchExpenses(forGroup groupId: Int, idToken: String) async throws -> [ExpenseResponse] {
        guard let url = URL(string: "\(baseURL)/get-expenses-by-groupid?groupId=\(groupId)") else {
            throw ExpenseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ExpenseError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([String: [ExpenseResponse]].self, from: data)

            guard let expenses = decoded["expenses"], !expenses.isEmpty else {
                throw ExpenseError.keyNotFound
            }
            
            return expenses
        } catch {
            print("Error fetching expenses:", error)
            throw ExpenseError.requestFailed
        }
    }
}
