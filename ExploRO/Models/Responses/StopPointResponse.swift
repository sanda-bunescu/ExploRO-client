struct StopPointResponse: Codable{
    var id: Int
    var itineraryId: Int
    var touristicAttraction: TouristicAttractionResponse
}
