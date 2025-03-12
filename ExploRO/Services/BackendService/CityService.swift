import Foundation

enum CityServiceError: Error {
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
    case cityAlreadyAdded
}

protocol CityServiceProtocol {
    func getAllCities(idToken : String) async throws -> [CityResponse]
    func getUserCities(idToken: String) async throws -> [CityResponse]
    func addCity(cityID: Int, idToken: String) async throws -> String
    func deleteCity(cityID: Int, idToken: String) async throws
}


class CityService: CityServiceProtocol{
    private let baseURL = "http://localhost:3000"
    func getUserCities(idToken: String) async throws -> [CityResponse]{
        guard let url = URL(string: "\(baseURL)/get-user-cities") else {
            throw CityServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CityServiceError.requestFailed
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let citiesResponse = try decoder.decode([String: [CityResponse]].self, from: data)
            
            return citiesResponse["user_cities"] ?? []
        }catch CityServiceError.requestFailed{
            throw CityServiceError.requestFailed
        } catch {
            throw CityServiceError.decodingError
        }
    }
    
    func getAllCities(idToken: String) async throws -> [CityResponse] {
        guard let url = URL(string: "\(baseURL)/get-cities") else {
            throw CityServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CityServiceError.requestFailed
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let citiesResponse = try decoder.decode([String: [CityResponse]].self, from: data)
            return citiesResponse["cities"] ?? []
        } catch {
            throw CityServiceError.decodingError
        }
    }
    
    func addCity(cityID: Int, idToken: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/add-user-city") else {
            return "Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let addCityRequest = AddCityRequest(cityID: cityID)
        
        do {
            // Encode the AddCityRequest object to JSON
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(addCityRequest)
            request.httpBody = jsonData
        } catch {
            return "Failed to encode city data"
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return "Request failed. Please try again later."
            }
            
            switch httpResponse.statusCode {
            case 200:
                return "City added successfully"
            case 400:
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                let errorMessage = errorResponse?.error ?? "City is already added on profile"
                return errorMessage
            default:
                return "Request failed. Please try again later."
            }
        } catch {
            return "Failed to perform the request. Please try again later."
        }
    }
    
    
    func deleteCity(cityID: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/delete-user-city") else {
            throw CityServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["cityID": cityID]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\(jsonString)")
            }
        } catch {
            print("JSON Encoding error")
            throw CityServiceError.encodingError
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CityServiceError.requestFailed
            }
        } catch {
            throw CityServiceError.decodingError
        }
    }
}
