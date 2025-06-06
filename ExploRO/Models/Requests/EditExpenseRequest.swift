import Foundation
struct EditExpenseRequest: Codable {
    var id: Int
    var name: String
    var amount: Double
    var type: String
    var date: Date
    var description: String
    var debtors: [DebtRequest]
}

extension EditExpenseRequest {
    init(from response: ExpenseResponse) {
        self.id = response.id
        self.name = response.name
        self.amount = response.amount
        self.type = response.type
        self.date = response.date
        self.description = response.description
        self.debtors = (response.debtors ?? []).map {
            DebtRequest(
                userId: $0.userId,
                amountToPay: $0.amountToPay
            )
        }
    }
}
