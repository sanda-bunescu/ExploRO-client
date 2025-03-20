import Foundation
enum TripPlanError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
}

protocol TripPlanServiceProtocol {
    func fetchTripPlansByUserId(idToken: String) async throws -> [TripPlanResponse]
    func fetchTripPlansByCityAndUser(idToken: String, cityId: Int) async throws -> [TripPlanResponse]
    func fetchTripPlansByGroupId(idToken: String, groupId: Int) async throws -> [TripPlanResponse]
    func createTripPlan(idToken: String, tripPlan: CreateTripPlanRequest) async throws
    func deleteTripPlan(idToken: String, tripPlanId: Int) async throws
}

class TripPlanService: TripPlanServiceProtocol {
    private let baseURL = "http://localhost:3000"
    func fetchTripPlansByUserId(idToken: String) async throws -> [TripPlanResponse] {
        guard let url = URL(string: "\(baseURL)/get-trip-by-user") else {
            throw TripPlanError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TripPlanError.requestFailed
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let tripsResponse = try decoder.decode([String: [TripPlanResponse]].self, from: data)
            
            return tripsResponse["trips"] ?? []
        } catch {
            throw TripPlanError.requestFailed
        }
    }
    
    func fetchTripPlansByCityAndUser(idToken: String, cityId: Int) async throws -> [TripPlanResponse] {
        guard let url = URL(string: "\(baseURL)/get-trip-by-city-and-user?cityId=\(cityId)") else {
            throw TripPlanError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TripPlanError.requestFailed
            }
            
            let rawJSON = String(data: data, encoding: .utf8)
            print("Raw JSON Response:", rawJSON ?? "Invalid data")

            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let tripsResponse = try decoder.decode([String: [TripPlanResponse]].self, from: data)
            
            return tripsResponse["trips"] ?? []
        } catch {
            throw TripPlanError.requestFailed
        }
    }
    
    func fetchTripPlansByGroupId(idToken: String, groupId: Int) async throws -> [TripPlanResponse] {
        guard let url = URL(string: "\(baseURL)/get-trips-by-group?groupId=\(groupId)") else {
            throw TripPlanError.invalidURL
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TripPlanError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let tripsResponse = try decoder.decode([String: [TripPlanResponse]].self, from: data)
            
            return tripsResponse["trips"] ?? []
        } catch {
            throw TripPlanError.requestFailed
        }
    }
    
    func createTripPlan(idToken: String, tripPlan: CreateTripPlanRequest) async throws {
        guard let url = URL(string: "\(baseURL)/create-trip") else {
            throw TripPlanError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let jsonData = try encoder.encode(tripPlan)
            request.httpBody = jsonData
        } catch {
            throw TripPlanError.encodingError
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TripPlanError.requestFailed
            }
            
        } catch {
            throw TripPlanError.requestFailed
        }
    }
    
    func deleteTripPlan(idToken: String, tripPlanId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/delete-trip?tripId=\(tripPlanId)") else {
            throw TripPlanError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TripPlanError.requestFailed
            }
        } catch {
            throw TripPlanError.requestFailed
        }
    }
    
    
    
}
