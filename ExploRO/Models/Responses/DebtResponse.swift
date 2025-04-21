struct DebtResponse: Codable{
    let id: Int
    let userId: String
    let userName: String
    var amountToPay: Double
}
