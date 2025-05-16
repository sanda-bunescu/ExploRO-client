struct LandmarkPredictionResponse: Decodable {
    let label: String
    let address: String?
    let lat: Double?
    let lon: Double?
}
