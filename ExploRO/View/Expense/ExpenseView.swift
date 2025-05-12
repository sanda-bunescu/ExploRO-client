import SwiftUI

struct ExpenseView: View {
    let expense: ExpenseResponse
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

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
            Button("Delete") {
                showDeleteConfirmation = true
            }
        }
        .sheet(isPresented: $isEditing) {
            EditExpenseView(
                viewModel: expenseViewModel,
                editRequest: EditExpenseRequest(from: expense),
                groupId: expense.groupId
            )
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Expense"),
                message: Text("Are you sure you want to delete this expense? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    Task{
                        await expenseViewModel.deleteExpense(expense: expense, user: authViewModel.user)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}


#Preview {
    let sampleExpense = ExpenseResponse(
        id: 21,
        name: "Lunch at Cafe",
        groupId: 87,
        payerUserName: "payerUser",
        date: Date(),
        amount: 18.99,
        description: "Shared lunch expense after team meeting",
        type: "Split Manually",
        debtors: [
            DebtResponse(id: 51, userId: "exHywIWyPyZbdwW2NrSFeE68QF33", userName: "testUser",amountToPay: 100)
        ]
    )

     NavigationView {
        ExpenseView(expense: sampleExpense, expenseViewModel: ExpenseViewModel())
         
             .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    }
}
