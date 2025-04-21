import Foundation
struct NewExpenseRequest: Codable{
    var name: String
    var groupId: Int
    var payerId: String
    var date: Date
    var amount: Double
    var description: String
    var type: String
    let debtors: [DebtRequest]
}
