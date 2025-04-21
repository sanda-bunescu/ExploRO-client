import Foundation
import FirebaseAuth

@MainActor
class TripPlanViewModel: ObservableObject{
    @Published var tripPlans: [TripPlanResponse] = []
    private let tripPlanService: TripPlanServiceProtocol
    @Published var errorMessage: String?
    @Published var showAlert = false

    
    
    init (tripPlanService: TripPlanServiceProtocol = TripPlanService()) {
        self.tripPlanService = tripPlanService
    }
    
    func fetchTripPlansByUserId(user: User?) async{
        guard let user = user else{
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedTrips = try await tripPlanService.fetchTripPlansByUserId(idToken: idToken)
            
            tripPlans = fetchedTrips
        } catch {
            errorMessage = "Failed to fetch trips"
        }
    }
    func fetchTripPlansByCityAndUser(user: User?, cityId: Int) async {
        guard let user = user else{
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedTrips = try await tripPlanService.fetchTripPlansByCityAndUser(idToken: idToken, cityId: cityId)
            
            tripPlans = fetchedTrips
        } catch {
            errorMessage = "Failed to fetch trips"
        }
    }
    func fetchTripPlansByGroupId(user: User?, groupId: Int) async{
        guard let user = user else{
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            print(idToken)
            let fetchedTrips = try await tripPlanService.fetchTripPlansByGroupId(idToken: idToken, groupId: groupId)
            
            tripPlans = fetchedTrips
            print(tripPlans.count)
        } catch {
            print("i am in catch")
            errorMessage = "Failed to fetch trips"
        }
    }
    func createTripPlan(user: User?, name: String, startDate: Date, endDate: Date, selectedGroupId: Int, selectedCityId: Int, baseGroupId: Int, baseCityId: Int) async{
        guard let user = user else{
            errorMessage = "User not authenticated"
            return
        }
        if name.isEmpty {
            errorMessage = "Please enter a trip name"
            showAlert = true
            return
        }
        if selectedGroupId == 0 || selectedCityId == 0 {
            showAlert = true
            errorMessage = "Please select both group and city"
            return
        }
        let isoFormatter = ISO8601DateFormatter()
        
        let formattedStartDate = isoFormatter.string(from: startDate)
        let formattedEndDate = isoFormatter.string(from: endDate)
        
        
        let createTripPlanRequest = CreateTripPlanRequest(
            tripName: name, startDate: formattedStartDate, endDate: formattedEndDate, groupId: selectedGroupId, cityId: selectedCityId
        )
        
        do{
            let idToken = try await user.getIDToken()
            try await tripPlanService.createTripPlan(idToken: idToken, tripPlan: createTripPlanRequest)
            
            if baseGroupId != 0 {
                await fetchTripPlansByGroupId(user: user, groupId: baseGroupId)
            }
            if baseCityId != 0 {
                await fetchTripPlansByCityAndUser(user: user, cityId: baseCityId)
            }
            if baseGroupId == 0 && baseCityId == 0{
                await fetchTripPlansByUserId(user: user)
            }
            errorMessage = "Trip plan created successfully"
            showAlert = true
        }catch{
            errorMessage = "Failed to create trip plan"
        }
    }
    func deleteTripPlan(user: User?, tripPlanId: Int, groupId: Int, cityId: Int) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await tripPlanService.deleteTripPlan(idToken: idToken, tripPlanId: tripPlanId)
            //fetch depending on parent view
            if groupId != 0 {
                await fetchTripPlansByGroupId(user: user, groupId: groupId)
            } else if cityId != 0 {
                await fetchTripPlansByCityAndUser(user: user, cityId: cityId)
            } else {
                await fetchTripPlansByUserId(user: user)
            }
        } catch {
            errorMessage = "Failed to delete trip plan"
        }
    }
}
