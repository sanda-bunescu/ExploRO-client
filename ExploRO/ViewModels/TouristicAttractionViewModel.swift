import SwiftUI
import FirebaseAuth

@MainActor
class TouristicAttractionViewModel: ObservableObject {
    @Published var attractions: [TouristicAttractionResponse] = []
    private let touristicAttractionService: TouristicAttractionServiceProtocol
    @Published var errorMessage: String?
    
    init(touristicAttractionService: TouristicAttractionServiceProtocol = TouristicAttractionService()) {
        self.touristicAttractionService = touristicAttractionService
    }
    
    func fetchTouristicAttractionsByCityId(cityId: Int) async{
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
    
    func fetchTouristicAttractionsNotInTripPlan(cityId: Int, user: User?, tripPlanId: Int) async{
        guard let user = user else{
            errorMessage = "User not authenticated"
            return
        }
        do {
            let idToken = try await user.getIDToken()
            var fetchedAttractions = try await touristicAttractionService.fetchTouristicAttractionsNotInTripPlan(tripPlanId: tripPlanId, cityId: cityId, idToken: idToken)
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
