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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Split Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if request.type == "Split Equally" {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Members to Split With")
                            .font(.headline)
                        
                        ForEach(members, id: \.userId) { member in
                            Toggle(isOn: Binding(
                                get: { selectedUserIds.contains(member.userId) },
                                set: { isOn in
                                    if isOn {
                                        selectedUserIds.insert(member.userId)
                                    } else {
                                        selectedUserIds.remove(member.userId)
                                    }
                                }
                            )) {
                                Text(memberDisplayName(member))
                                    .font(.body)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Manual Amounts Per Member")
                            .font(.headline)
                        
                        ForEach(members, id: \.userId) { member in
                            HStack {
                                Text(memberDisplayName(member))
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
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }

                Button(action: saveExpense) {
                    Text("Save Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSaveDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isSaveDisabled)
            }
            .padding()
        }
        .navigationTitle("Split Details")
        .alert("Error", isPresented: $expenseViewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(expenseViewModel.errorMessage ?? "Something went wrong.")
        }
    }
    
    private func memberDisplayName(_ member: GroupUserResponse) -> String {
        member.userName.isEmpty ? member.userEmail : member.userName
    }
    
    private var isSaveDisabled: Bool {
        (request.type == "Split Equally" && selectedUserIds.isEmpty) ||
        (request.type == "Split Manually" && manualAmounts.values.allSatisfy { $0.isEmpty })
    }
    
    private func saveExpense() {
        if request.type == "Split Equally" {
            Task {
                await expenseViewModel.saveExpensesEqually(
                    expense: request,
                    selectedUserIds: selectedUserIds,
                    user: authViewModel.user
                )
            }
        } else {
            Task {
                let success = await expenseViewModel.saveExpensesManually(
                    expense: request,
                    manualAmounts: manualAmounts,
                    user: authViewModel.user
                )
                if success {
                    dismiss()
                }
            }
        }
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

