import Foundation

enum TouristicAttractionError: Error{
    case invalidURL
    case requestFailed
    case decodingError
    case encodingError
}

protocol TouristicAttractionServiceProtocol {
    func fetchTouristicAttractionsByCityId(cityId: Int) async throws -> [TouristicAttractionResponse]
}

class TouristicAttractionService: TouristicAttractionServiceProtocol {
    let baseURL = "http://localhost:3000"
    
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
