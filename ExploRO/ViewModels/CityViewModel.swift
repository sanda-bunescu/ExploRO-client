import SwiftUI
import FirebaseAuth

@MainActor
class CityViewModel: ObservableObject {
    @Published var cities: [CityResponse] = []
    private let cityService: CityServiceProtocol
    @Published var errorMessage: String?
    
    init(cityService: CityServiceProtocol = CityService()) {
        self.cityService = cityService
    }
    
    func fetchAllCities(user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            var fetchedCities = try await cityService.getAllCities(idToken: idToken)
            fetchedCities = fetchedCities.map { city in
                var modifiedCity = city
                if let imageUrl = city.imageUrl, !imageUrl.isEmpty {
                    modifiedCity.imageUrl = "\(AppConfig.baseURL)\(imageUrl)"
                }
                return modifiedCity
            }
            self.cities = fetchedCities
        } catch {
            errorMessage = "Failed to fetch cities"
        }
    }
    
    func fetchCitiesNotSavedByUser(user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let allCities = try await cityService.getAllCities(idToken: idToken)
            let savedCities = try await cityService.getUserCities(idToken: idToken)
            
            // Filter out cities that are already saved
            let savedCityIDs = Set(savedCities.map { $0.id })
            var unsaved = allCities.filter { !savedCityIDs.contains($0.id) }
            unsaved = unsaved.map { city in
                var modifiedCity = city
                if let imageUrl = city.imageUrl, !imageUrl.isEmpty {
                    modifiedCity.imageUrl = "\(AppConfig.baseURL)\(imageUrl)"
                }
                return modifiedCity
            }
            self.cities = unsaved
        } catch {
            errorMessage = "Failed to fetch unsaved cities"
        }
    }
}
