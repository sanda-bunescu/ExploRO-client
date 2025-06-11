import SwiftUI
import FirebaseAuth

@MainActor
class ItineraryViewModel: ObservableObject{
    @Published var itineraryList: [ItineraryResponse] = []
    
    @Published var errorMessage: String?
    @Published var showErrorMessage: Bool = false
    private let itineraryService: ItineraryServiceProtocol
    
    init(itineraryService: ItineraryServiceProtocol = ItineraryService()) {
        self.itineraryService = itineraryService
    }
    
    // Fetch all itineraries for a given trip plan
    func fetchItineraries(tripPlanId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedItineraries = try await itineraryService.getAllItinerariesByTripPlanId(tripPlanId: tripPlanId, idToken: idToken)
            self.itineraryList = fetchedItineraries
        } catch {
            self.errorMessage = "Failed to fetch itineraries: \(error.localizedDescription)"
        }
    }
    
    // Create a new itinerary in a trip plan
    func addItinerary(tripPlanId: Int, tripStartDate: Date, tripEndDate: Date, user: User?) async -> Int{
        guard let user = user else {
            errorMessage = "User not authenticated"
            return 0
        }
        
        do {
            let idToken = try await user.getIDToken()
            await fetchItineraries(tripPlanId: tripPlanId, user: user)

            let calendar = Calendar.current
            let numberOfDays = calendar.dateComponents([.day], from: tripStartDate, to: tripEndDate).day ?? 0
            let totalDays = numberOfDays + 1

            let usedDayNumbers = itineraryList.map { $0.dayNr }
            let nextDayNumber = (usedDayNumbers.max() ?? 0) + 1
            if nextDayNumber > totalDays {
                self.errorMessage = "Trip only has \(totalDays) day(s). You already used all available days."
                self.showErrorMessage = true
                return 0
            }
            
            
            //create itinerary
            let newItinerary = try await itineraryService.createItineraryInTripPlan(tripPlanId: tripPlanId, idToken: idToken)
            await fetchItineraries(tripPlanId: tripPlanId, user: user)
            
            return newItinerary.id
        } catch {
            self.showErrorMessage = true
            self.errorMessage = "Failed to create itinerary: \(error.localizedDescription)"
            return 0
        }
    }
    
    // Delete an itinerary by its ID
    func removeItinerary(itineraryId: Int, tripPlanId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await itineraryService.deleteItinerary(itineraryId: itineraryId, idToken: idToken)
            await fetchItineraries(tripPlanId: tripPlanId, user: user)
        } catch {
            self.showErrorMessage = true
            self.errorMessage = "Failed to delete itinerary: \(error.localizedDescription)"
        }
    }
}
