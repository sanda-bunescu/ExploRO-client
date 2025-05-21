import SwiftUI
import FirebaseAuth

@MainActor
class StopPointViewModel: ObservableObject{
    @Published var stopPoints: [StopPointResponse] = []
    @Published var errorMessage: String?
    
    private let stopPointService: StopPointServiceProtocol
    
    init(stopPointService: StopPointServiceProtocol = StopPointService()) {
        self.stopPointService = stopPointService
    }
    
    func fetchStopPoints(itineraryId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            var fetchedStopPoints = try await stopPointService.getAllTouristicAttractionsByItineraryId(itineraryId: itineraryId, idToken: idToken)
            fetchedStopPoints = fetchedStopPoints.map { stopPoint in
                var modifiedStopPoint = stopPoint
                if let imageUrl = stopPoint.touristicAttraction.imageUrl, !imageUrl.isEmpty, !imageUrl.starts(with: "http") {
                    modifiedStopPoint.touristicAttraction.imageUrl = "\(AppConfig.baseURL)\(imageUrl)"
                }
                return modifiedStopPoint
            }
            self.stopPoints = fetchedStopPoints

        } catch {
            self.errorMessage = "Failed to fetch stop points: \(error.localizedDescription)"
        }
    }
    
    func addStopPoints(ids: [Int], itineraryId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await stopPointService.addTouristicAttractionsToItinerary(ids: ids, itineraryId: itineraryId, idToken: idToken)
            await fetchStopPoints(itineraryId: itineraryId, user: user)
        } catch {
            self.errorMessage = "Failed to add stop points: \(error.localizedDescription)"
        }
    }
    
    func removeStopPoint(stopPointId: Int, itineraryId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await stopPointService.deleteTouristicAttractionFromItinerary(stopPointId: stopPointId, idToken: idToken)
            if let index = stopPoints.firstIndex(where: { $0.id == stopPointId }) {
                stopPoints.remove(at: index)
            }
        } catch {
            self.errorMessage = "Failed to remove stop point: \(error.localizedDescription)"
        }
    }
}

