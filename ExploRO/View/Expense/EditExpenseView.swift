import SwiftUI

struct EditExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel
    @State var editRequest: EditExpenseRequest
    @State private var showDebtorsEditor = false
    let groupId: Int

    init(viewModel: ExpenseViewModel, editRequest: EditExpenseRequest, groupId: Int) {
        self.viewModel = viewModel
        self._editRequest = State(initialValue: editRequest)
        self.groupId = groupId
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Edit Expense")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    CustomTextField(title: "Name", text: $editRequest.name)

                    CustomTextField(title: "Description", text: $editRequest.description)


                    VStack(alignment: .leading, spacing: 10) {
                        Text("Date")
                            .font(.headline)
                        DatePicker("", selection: $editRequest.date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    Button("Edit Debtors") {
                        showDebtorsEditor = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .sheet(isPresented: $showDebtorsEditor) {
                        EditSplitExpenseView(
                            editRequest: $editRequest,
                            viewModel: viewModel,
                            groupId: groupId
                        )
                    }

                    Button("Save") {
                        Task {
                            await viewModel.editExpense(
                                expense: editRequest,
                                user: authViewModel.user,
                                groupId: groupId
                            )
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
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
