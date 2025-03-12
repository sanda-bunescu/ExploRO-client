import SwiftUI

@MainActor
class CityAttractionViewModel: ObservableObject {
    @Published var attractions: [TouristicAttractionResponse] = []
    private let touristicAttractionService: TouristicAttractionServiceProtocol
    @Published var errorMessage: String?
    
    init(touristicAttractionService: TouristicAttractionServiceProtocol = TouristicAttractionService()) {
        self.touristicAttractionService = touristicAttractionService
    }
    
    func fetchAllByCityId(cityId: Int) async{
        do {
            var fetchedAttractions = try await touristicAttractionService.fetchTouristicAttractionsByCityId(cityId: cityId)
            fetchedAttractions = fetchedAttractions.map { attraction in
                var modifiedAttraction = attraction
                if let imageUrl = attraction.imageUrl, !imageUrl.isEmpty {
                    modifiedAttraction.imageUrl = "http://localhost:3000\(imageUrl)"
                }
                return modifiedAttraction
            }
            self.attractions = fetchedAttractions
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
