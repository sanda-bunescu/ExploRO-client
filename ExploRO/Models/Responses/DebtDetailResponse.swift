struct DebtDetailResponse: Codable{
    let id: Int
    let userId: String
    let userName: String
    let amountToPay: Double
    let payerId: String
    let payerName: String
}

