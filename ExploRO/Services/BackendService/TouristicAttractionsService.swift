import Foundation

enum TouristicAttractionError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
}

protocol TouristicAttractionServiceProtocol {
    func fetchTouristicAttractionsNotInTripPlan(tripPlanId: Int, cityId: Int, idToken: String) async throws -> [TouristicAttractionResponse]
    func fetchTouristicAttractionsByCityId(cityId: Int) async throws -> [TouristicAttractionResponse]
}

class TouristicAttractionService: TouristicAttractionServiceProtocol {
    let baseURL = "http://localhost:3000"
    
    func fetchTouristicAttractionsNotInTripPlan(tripPlanId: Int, cityId: Int, idToken: String) async throws -> [TouristicAttractionResponse]{
        guard let url = URL(string: "\(baseURL)/attractions/not-in-itinerary?cityId=\(cityId)&tripPlanId=\(tripPlanId)") else {
            throw TouristicAttractionError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ItineraryError.requestFailed
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let touristicAttractions = try decoder.decode([String:[TouristicAttractionResponse]].self, from: data)
             
            guard let toursticAttractionsList = touristicAttractions["touristic_attractions"] else {
                throw ItineraryError.keyNotFound
            }
            return toursticAttractionsList
        } catch {
            throw ItineraryError.requestFailed
        }
    }
    
    func fetchTouristicAttractionsByCityId(cityId: Int) async throws -> [TouristicAttractionResponse] {
        guard let url = URL(string: "\(baseURL)/get-attractions-by-cityid?cityId=\(cityId)") else {
            throw TouristicAttractionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw TouristicAttractionError.requestFailed
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let touristicAttractionsResponse = try decoder.decode([String: [TouristicAttractionResponse]].self, from: data)
            return touristicAttractionsResponse["touristic_attractions"] ?? []
        }catch TouristicAttractionError.requestFailed{
            throw TouristicAttractionError.requestFailed
        }catch{
            throw TouristicAttractionError.decodingError
        }
    }
}
