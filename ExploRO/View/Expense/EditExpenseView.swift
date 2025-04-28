import SwiftUI

struct EditExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel
    @State var editRequest: EditExpenseRequest
    @State private var showDebtorsEditor = false
    let groupId: Int

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Name", text: $editRequest.name)
                TextField("Amount", value: $editRequest.amount, formatter: NumberFormatter())
                Picker("Type", selection: $editRequest.type) {
                    Text("Split Equally").tag("Split Equally")
                    Text("Split Manually").tag("Split Manually")
                }
                DatePicker("Date", selection: $editRequest.date, displayedComponents: .date)
                TextField("Description", text: $editRequest.description)
            }

            Button("Edit Debtors") {
                showDebtorsEditor = true
            }
            .sheet(isPresented: $showDebtorsEditor) {
                EditSplitExpenseView(editRequest: $editRequest, viewModel: viewModel, groupId: groupId)
            }



            Button("Save") {
                Task {
                    await viewModel.editExpense(expense: editRequest, user: authViewModel.user, groupId: groupId)
                    
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Expense")
        
    }
}

#Preview {
    let sampleRequest = EditExpenseRequest(
        id: 1,
        name: "Lunch at Cafe",
        amount: 18.99,
        type: "Split Equally",
        date: Date(),
        description: "Shared lunch with group",
        debtors: [
            DebtRequest(userId: "user_1", amountToPay: 6.33),
            DebtRequest(userId: "user_2", amountToPay: 6.33)
        ]
    )

    return NavigationView {
        EditExpenseView(viewModel: ExpenseViewModel(), editRequest: sampleRequest, groupId: 1).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))

    }
}
