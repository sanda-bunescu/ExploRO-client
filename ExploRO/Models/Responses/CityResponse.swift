import Foundation

struct CityResponse: Codable {
    let id: Int
    var cityName: String
    let cityDescription: String
    var imageUrl: String?
}


