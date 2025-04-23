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
    func saveExpense(_ expense: NewExpenseRequest, idToken: String) async throws

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
    
    func saveExpense(_ expense: NewExpenseRequest, idToken: String) async throws {
        
        guard let url = URL(string: "\(baseURL)/save-expense") else {
            throw ExpenseError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(expense)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GroupError.requestFailed(message: "No response from server.")
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    throw GroupError.requestFailed(message: errorMessage)
                } else {
                    throw GroupError.requestFailed(message: "Unknown error occurred.")
                }
            }
        } catch {
            print("Error saving expense:", error)
            throw ExpenseError.encodingError
        }
    }

}
