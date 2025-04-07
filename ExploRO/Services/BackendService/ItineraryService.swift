import Foundation

enum ItineraryError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
    case keyNotFound
}

protocol ItineraryServiceProtocol {
    func getAllItinerariesByTripPlanId(tripPlanId: Int, idToken: String) async throws -> [ItineraryResponse]
    func createItineraryInTripPlan(tripPlanId: Int, idToken: String) async throws -> ItineraryResponse
    func deleteItinerary(itineraryId: Int, idToken: String) async throws
}

class ItineraryService: ItineraryServiceProtocol {
    let baseURL = "http://localhost:3000"
    func getAllItinerariesByTripPlanId(tripPlanId: Int, idToken: String) async throws -> [ItineraryResponse] {
        guard let url = URL(string: "\(baseURL)/get-all-itineraries-by-trip-plan-id?tripPlanId=\(tripPlanId)") else{
            throw ItineraryError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ItineraryError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let itineraries = try decoder.decode([String: [ItineraryResponse]].self, from: data)
            guard let itineraryList = itineraries["itineraries"], !itineraryList.isEmpty else {
                throw ItineraryError.keyNotFound
            }
            return itineraryList
        }catch{
            throw ItineraryError.requestFailed
        }
        
    }
    
    func createItineraryInTripPlan(tripPlanId: Int, idToken: String) async throws -> ItineraryResponse {
        guard let url = URL(string: "\(baseURL)/create-itinerary?tripPlanId=\(tripPlanId)") else{
            throw ItineraryError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ItineraryError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let itinerary = try decoder.decode([String: ItineraryResponse].self, from: data)
            
            guard let itinerary = itinerary["itinerary"] else {
                throw ItineraryError.keyNotFound
            }
            return itinerary
        }catch{
            print("error here")
            throw ItineraryError.requestFailed
        }
    }
    
    func deleteItinerary(itineraryId: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/delete-itinerary?itineraryId=\(itineraryId)") else{
            throw ItineraryError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ItineraryError.requestFailed
            }
        }catch{
            throw ItineraryError.requestFailed
        }
    }
}
