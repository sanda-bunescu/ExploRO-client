import Foundation

enum StopPointError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
    case keyNotFound
}

protocol StopPointServiceProtocol {
    func getAllTouristicAttractionsByItineraryId(itineraryId: Int, idToken: String) async throws -> [StopPointResponse]
    func addTouristicAttractionsToItinerary(ids: [Int], itineraryId: Int, idToken: String) async throws
    func deleteTouristicAttractionFromItinerary(stopPointId: Int, idToken: String) async throws
}

class StopPointService: StopPointServiceProtocol {
    let baseURL = "http://localhost:3000"
    func getAllTouristicAttractionsByItineraryId(itineraryId: Int, idToken: String) async throws -> [StopPointResponse] {
        guard let url = URL(string: "\(baseURL)/get-all-attractions-by-itinerary-id?itineraryId=\(itineraryId)") else{
            throw StopPointError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw StopPointError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let stopPoints = try decoder.decode([String: [StopPointResponse]].self, from: data)
            guard let stopPointsList = stopPoints["stopPoints"], !stopPointsList.isEmpty else {
                throw StopPointError.keyNotFound
            }
            return stopPointsList
        }catch{
            throw StopPointError.requestFailed
        }
    }
    
    func addTouristicAttractionsToItinerary(ids: [Int], itineraryId: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/add-touristic-attractions-itinerary?itineraryId=\(itineraryId)") else{
            throw StopPointError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: ["ids": ids], options: [])
            request.httpBody = jsonData
        } catch {
            throw StopPointError.encodingError
        }
        
        do{
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw StopPointError.requestFailed
            }
        }catch{
            throw StopPointError.requestFailed
        }
    }
    
    func deleteTouristicAttractionFromItinerary(stopPointId: Int, idToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/delete-touristic-attraction?stopPointId=\(stopPointId)") else {
            throw ItineraryError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw StopPointError.requestFailed
            }
        } catch {
            throw StopPointError.requestFailed
        }
    }
    
}
