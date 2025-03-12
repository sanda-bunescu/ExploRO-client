import Foundation

struct CityResponse: Codable {
    let id: Int
    let cityName: String
    let cityDescription: String
    var imageUrl: String?
}


