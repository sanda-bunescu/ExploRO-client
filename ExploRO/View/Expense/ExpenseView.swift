import SwiftUI

struct ExpenseView: View {
    let expense: ExpenseResponse
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(expense.name)
                .font(.largeTitle)
                .bold()

            HStack {
                Text("Amount:")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", expense.amount))
                    .font(.title2)
                    .bold()
            }

            HStack {
                Text("Type:")
                    .font(.headline)
                Spacer()
                Text(expense.type)
            }

            HStack {
                Text("Date:")
                    .font(.headline)
                Spacer()
                Text(expense.date.formatted(date: .long, time: .omitted))
            }

            HStack {
                Text("Group ID:")
                    .font(.headline)
                Spacer()
                Text("\(expense.groupId)")
            }

            HStack {
                Text("Payer:")
                    .font(.headline)
                Spacer()
                Text("\(expense.payerUserName)")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Description:")
                    .font(.headline)
                Text(expense.description)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Debts")
                    .font(.headline)

                if(expense.debtors ?? []).isEmpty {
                    Text("No one owes for this expense.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(expense.debtors ?? [], id: \.id) { debt in
                        HStack {
                            Text(debt.userName)
                            Spacer()
                            Text(String(format: "$%.2f", debt.amountToPay))
                                .bold()
                        }
                        .font(.subheadline)
                    }
                }
            }
            Spacer()

        }
        .padding()
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") {
                isEditing = true
            }
        }
        .sheet(isPresented: $isEditing) {
            EditExpenseView(
                viewModel: expenseViewModel,
                editRequest: EditExpenseRequest(from: expense)
            )
        }
    }
}


#Preview {
    let sampleExpense = ExpenseResponse(
        id: 1,
        name: "Lunch at Cafe",
        groupId: 45,
        payerUserName: "payerUser",
        date: Date(),
        amount: 18.99,
        description: "Shared lunch expense after team meeting",
        type: "Food",
        debtors: [
            DebtResponse(id: 1, userId: "userId1", userName: "testUser",amountToPay: 6.33),
            DebtResponse(id: 2, userId: "userId2", userName: "testUser2",amountToPay: 6.33)
        ]
    )

     NavigationView {
        ExpenseView(expense: sampleExpense, expenseViewModel: ExpenseViewModel())
    }
}
