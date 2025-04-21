import SwiftUI

struct EditExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel
    @State var editRequest: EditExpenseRequest
    @State private var showDebtorsEditor = false


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
                EditSplitExpenseView(editRequest: $editRequest)
            }



            Button("Save") {
                Task {
                    // Handle save action here if needed
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
            DebtResponse(id: 1, userId: "user_1", userName: "Alice", amountToPay: 6.33),
            DebtResponse(id: 2, userId: "user_2", userName: "Bob", amountToPay: 6.33)
        ]
    )

    return NavigationView {
        EditExpenseView(viewModel: ExpenseViewModel(), editRequest: sampleRequest).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))

    }
}
