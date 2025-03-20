import Foundation
struct CreateTripPlanRequest: Codable{
    let tripName: String
    let startDate: String
    let endDate: String
    let groupId: Int
    let cityId: Int
}
