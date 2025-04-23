import SwiftUI

struct SplitExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    
    let request: NewExpenseRequest
    let members: [GroupUserResponse]
    
    @State private var selectedUserIds: Set<String> = []
    @State private var manualAmounts: [String: String] = [:]
    
    var body: some View {
        Form {
            if request.type == "Split Equally" {
                Section(header: Text("Select Members to Split With")) {
                    ForEach(members, id: \.userId) { member in
                        Toggle(member.userName.isEmpty ? member.userEmail : member.userName, isOn: Binding(
                            get: { selectedUserIds.contains(member.userId) },
                            set: { isOn in
                                if isOn {
                                    selectedUserIds.insert(member.userId)
                                } else {
                                    selectedUserIds.remove(member.userId)
                                }
                            }
                        ))
                    }
                }
            } else {
                Section(header: Text("Manual Amounts Per Member")) {
                    ForEach(members, id: \.userId) { member in
                        HStack {
                            Text(member.userName.isEmpty ? member.userEmail : member.userName)
                            Spacer()
                            TextField("Amount", text: Binding(
                                get: { manualAmounts[member.userId] ?? "" },
                                set: { newValue in
                                    let sanitized = newValue.replacingOccurrences(of: ",", with: ".")
                                    let pattern = #"^\d*(\.\d{0,2})?$"#
                                    
                                    if sanitized.isEmpty || sanitized.range(of: pattern, options: .regularExpression) != nil {
                                        manualAmounts[member.userId] = sanitized
                                    }
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                        }
                    }
                }
            }
            
            Button("Save Expense") {
                if request.type == "Split Equally" {
                    Task{
                        await expenseViewModel.saveExpensesEqually(expense: request, selectedUserIds: selectedUserIds, user: authViewModel.user )
                    }
                } else {
                    Task{
                        let success = await expenseViewModel.saveExpensesManually(expense: request, manualAmounts: manualAmounts, user: authViewModel.user )
                        if success {
                            dismiss()
                        }
                    }
                }
            }
            .disabled(
                (request.type == "Split Equally" && selectedUserIds.isEmpty) ||
                (request.type == "Split Manually" && manualAmounts.values.allSatisfy { $0.isEmpty })
            )
        }
        .navigationTitle("Split Details")
        .alert("Error", isPresented: $expenseViewModel.showAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(expenseViewModel.errorMessage ?? "Something went wrong.")
        })
    }
}


#Preview {
    let mockRequest = NewExpenseRequest(
        name: "Dinner",
        groupId: 101,
        payerId: "1",
        date: Date(),
        amount: 45.50,
        description: "Team dinner at restaurant",
        type: "Split Manually", // or "Split Equally"
        debtors: []
    )
    
    return SplitExpenseView(
        expenseViewModel: ExpenseViewModel(),
        request: mockRequest,
        members: [
            GroupUserResponse(userId: "1", userName: "Alice", userEmail: "alice@email.com"),
            GroupUserResponse(userId: "2", userName: "Bob", userEmail: "bob@email.com"),
            GroupUserResponse(userId: "3", userName: "Charlie", userEmail: "charlie@email.com")
        ]
    ).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}

