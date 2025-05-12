import SwiftUI

struct EditSplitExpenseView: View {
    @StateObject private var groupViewModel = GroupViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var editRequest: EditExpenseRequest
    @ObservedObject var viewModel: ExpenseViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    
    let groupId: Int
    
    @State private var selectedUserIds: Set<String> = []
    @State private var manualAmounts: [String: String] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Split")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Type")
                        .font(.headline)

                    Picker("Type", selection: $editRequest.type) {
                        Text("Split Equally").tag("Split Equally")
                        Text("Split Manually").tag("Split Manually")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount")
                        .font(.headline)

                    TextField("Enter amount", value: $editRequest.amount, format: .number)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                if editRequest.type == "Split Equally" {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Members to Split With")
                            .font(.headline)
                        
                        ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                            Toggle(isOn: Binding(
                                get: { selectedUserIds.contains(member.userId) },
                                set: { isOn in
                                    if isOn {
                                        selectedUserIds.insert(member.userId)
                                    } else {
                                        selectedUserIds.remove(member.userId)
                                    }
                                    viewModel.updateSplitEquallyDebtors(
                                        selectedUserIds: selectedUserIds,
                                        totalAmount: editRequest.amount,
                                        editRequest: &editRequest
                                    )
                                }
                            )) {
                                Text(memberDisplayName(member))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                } else if editRequest.type == "Split Manually" {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Manual Amounts Per Member")
                            .font(.headline)
                        
                        ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                            HStack {
                                Text(memberDisplayName(member))
                                Spacer()
                                
                                let userId = member.userId
                                let binding = Binding<String>(
                                    get: {
                                        manualAmounts[userId] ??
                                        String(format: "%.2f", editRequest.debtors.first(where: { $0.userId == userId })?.amountToPay ?? 0)
                                    },
                                    set: { newValue in
                                        let sanitized = newValue.replacingOccurrences(of: ",", with: ".")
                                        let pattern = #"^\d*(\.\d{0,2})?$"#
                                        if sanitized.isEmpty || sanitized.range(of: pattern, options: .regularExpression) != nil {
                                            manualAmounts[userId] = sanitized
                                            updateDebtorAmount(userId: userId, newValue: sanitized)
                                        }
                                    }
                                )
                                
                                TextField("Amount", text: binding)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.trailing)
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
                
                VStack(alignment: .leading, spacing: 10) {
                    let total = editRequest.debtors.reduce(0) { $0 + $1.amountToPay }
                    let isValid = abs(total - editRequest.amount) < 0.01
                    
                    Button("Save") {
                        Task {
                            await viewModel.editExpense(expense: editRequest, user: authViewModel.user, groupId: groupId)
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isValid)
                    
                    if !isValid {
                        Text("Total of all debts (\(String(format: "%.2f", total))) must equal the expense amount (\(String(format: "%.2f", editRequest.amount))).")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Edit Split")
        .onAppear {
            Task {
                await groupViewModel.fetchUsersByGroupId(groupId: groupId, user: authViewModel.user)
                
                if editRequest.type == "Split Equally" {
                    selectedUserIds = Set(editRequest.debtors.map { $0.userId })
                    viewModel.updateSplitEquallyDebtors(selectedUserIds: selectedUserIds, totalAmount: editRequest.amount, editRequest: &editRequest)
                } else {
                    for debt in editRequest.debtors {
                        manualAmounts[debt.userId] = String(format: "%.2f", debt.amountToPay)
                    }
                }
            }
        }
        .onChange(of: editRequest.amount) {
            if editRequest.type == "Split Equally" {
                viewModel.updateSplitEquallyDebtors(
                    selectedUserIds: selectedUserIds,
                    totalAmount: editRequest.amount,
                    editRequest: &editRequest
                )
            }
        }
        .onChange(of: editRequest.type) {
            if editRequest.type == "Split Equally" {
                selectedUserIds = Set(groupViewModel.groupMembers.map { $0.userId })
                viewModel.updateSplitEquallyDebtors(
                    selectedUserIds: selectedUserIds,
                    totalAmount: editRequest.amount,
                    editRequest: &editRequest
                )
            } else {
                editRequest.debtors = []
                manualAmounts = [:]
            }
        }
    }
    
    private func updateDebtorAmount(userId: String, newValue: String) {
        if let amount = Double(newValue), amount > 0 {
            if let index = editRequest.debtors.firstIndex(where: { $0.userId == userId }) {
                editRequest.debtors[index].amountToPay = amount
            } else {
                editRequest.debtors.append(DebtRequest(userId: userId, amountToPay: amount))
            }
        } else {
            editRequest.debtors.removeAll { $0.userId == userId }
        }
    }
    
    private func memberDisplayName(_ member: GroupUserResponse) -> String {
        member.userName.isEmpty ? member.userEmail : member.userName
    }
}

#Preview {
    @Previewable @State var sampleRequest = EditExpenseRequest(
        id: 1,
        name: "Dinner",
        amount: 15.0,
        type: "Split Manually",
        date: Date(),
        description: "Team dinner",
        debtors: [
            DebtRequest(userId: "1", amountToPay: 15.0)
        ]
    )
    EditSplitExpenseView(editRequest: $sampleRequest, viewModel: ExpenseViewModel(), groupId: 87).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
