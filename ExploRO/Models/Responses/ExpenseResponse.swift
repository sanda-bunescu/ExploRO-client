import Foundation
struct ExpenseWrapper: Decodable {
    let expenses: [ExpenseResponse]?
}

struct ExpenseResponse: Codable, Identifiable{
    let id: Int
    let name: String
    let groupId: Int
    let payerUserName: String
    let date: Date
    let amount: Double
    let description: String
    let type: String
    let debtors: [DebtResponse]?
}
