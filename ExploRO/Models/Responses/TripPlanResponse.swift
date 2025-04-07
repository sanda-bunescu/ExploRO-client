import Foundation
struct TripPlanResponse :Identifiable, Codable {
    let id: Int
    var tripName: String
    var startDate: Date
    var endDate: Date
    var groupName: String
    var cityName: String
    var cityId: Int
}
