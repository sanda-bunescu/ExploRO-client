import SwiftUI
import FirebaseAuth

@MainActor
class UserCityViewModel: ObservableObject {
    @Published var cities: [CityResponse] = []
    private let cityService: CityServiceProtocol
    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    
    init(cityService: CityServiceProtocol = CityService()) {
        self.cityService = cityService
    }
    
    func fetchUserCities(user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            //print("ID Token of authenticated user is: \(idToken)")
            var fetchedCities = try await cityService.getUserCities(idToken: idToken)
            fetchedCities = fetchedCities.map { city in
                var modifiedCity = city
                if let imageUrl = city.imageUrl, !imageUrl.isEmpty {
                    modifiedCity.imageUrl = "\(AppConfig.baseURL)\(imageUrl)"
                }
                return modifiedCity
            }
            self.cities = fetchedCities
        } catch {
            print("Error fetching cities: \(error)")
            errorMessage = "Failed to fetch user cities"
        }
    }
    
    func addCityToUser(cityID: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        do {
            let message = try await cityService.addCity(cityID: cityID, idToken: user.getIDToken())
            errorMessage = message
            if message == "City added successfully" {
                //await fetchUserCities(user: user)
                errorMessage = message//this is not an error, is just success message
                showAlert = true
            } else {
                errorMessage = message
                showAlert = true
            }
            
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func deleteUserCity(cityID: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            try await cityService.deleteCity(cityID: cityID, idToken: user.getIDToken())
            errorMessage = "City deleted successfully"
            showAlert = true
            await fetchUserCities(user: user)
        } catch {
            print("Failed to delete city: \(error)")
        }
    }
}
