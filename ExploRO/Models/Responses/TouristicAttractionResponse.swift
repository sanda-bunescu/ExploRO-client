struct TouristicAttractionResponse: Codable {
    let id: Int
    let attractionName: String
    let attractionDescription: String
    let category: String
    var imageUrl: String?
    let openHours: String
    let fee: Float
    let link: String
}
