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
        if editRequest.type == "Split Equally" {
            Section(header: Text("Select Members to Split With")) {
                ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                    Toggle(member.userName.isEmpty ? member.userEmail : member.userName, isOn: Binding(
                        get: {
                            selectedUserIds.contains(member.userId) ||
                            editRequest.debtors.contains { $0.userId == member.userId }
                        },
                        set: { isOn in
                            if isOn {
                                selectedUserIds.insert(member.userId)
                            } else {
                                selectedUserIds.remove(member.userId)
                            }
                            viewModel.updateSplitEquallyDebtors(selectedUserIds: selectedUserIds, totalAmount: editRequest.amount, editRequest: &editRequest)
                        }
                    ))
                }
            }
        }else if editRequest.type == "Split Manually" {
            Section(header: Text("Assign Manual Amounts")) {
                ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                    HStack {
                        Text(member.userName.isEmpty ? member.userEmail : member.userName)
                        Spacer()
                        let userId = member.userId
                        let currentAmountString = {
                            if let debt = editRequest.debtors.first(where: { $0.userId == userId }) {
                                return String(format: "%.2f", debt.amountToPay)
                            }
                            return ""
                        }()
                        
                        let amountBinding = Binding<String>(
                            get: { currentAmountString },
                            set: { newValue in
                                manualAmounts[userId] = newValue
                                if let amount = Double(newValue), amount > 0{
                                    if let index = editRequest.debtors.firstIndex(where: { $0.userId == userId }) {
                                        var updatedDebtors = editRequest.debtors
                                        updatedDebtors[index].amountToPay = amount
                                        editRequest.debtors = updatedDebtors
                                    } else {
                                        let newDebt = DebtRequest(userId: userId, amountToPay: amount)
                                        editRequest.debtors.append(newDebt)
                                    }
                                }else {
                                    editRequest.debtors.removeAll { $0.userId == userId }
                                }
                            }
                        )
                        
                        TextField("Amount", text: amountBinding)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        Section {
            let totalDebtAmount = editRequest.debtors.reduce(0) { $0 + $1.amountToPay }
            let amountsMatch = abs(totalDebtAmount - editRequest.amount) < 0.01
            
            Button {
                Task {
                    await viewModel.editExpense(expense: editRequest, user: authViewModel.user, groupId: groupId)
                    dismiss()
                }
            } label: {
                Text("Save")
                    .padding()
                    .background(amountsMatch ? Color.accentColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!amountsMatch)
            
            if !amountsMatch {
                Text("The total of all debts (\(String(format: "%.2f", totalDebtAmount))) must equal the expense amount (\(String(format: "%.2f", editRequest.amount))).")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        
        .onAppear {
            Task {
                await groupViewModel.fetchUsersByGroupId(groupId: groupId, user: authViewModel.user)
                if editRequest.type == "Split Equally" {
                    selectedUserIds = Set(editRequest.debtors.map { $0.userId })
                    viewModel.updateSplitEquallyDebtors(selectedUserIds: selectedUserIds, totalAmount: editRequest.amount, editRequest: &editRequest)
                }
                
            }
        }
        
    }
}

#Preview {
    @Previewable @State var sampleRequest = EditExpenseRequest(
        id: 1,
        name: "Dinner",
        amount: 60.0,
        type: "Split Equally",
        date: Date(),
        description: "Team dinner",
        debtors: [
            DebtRequest(userId: "1", amountToPay: 30.0),
            DebtRequest(userId: "2", amountToPay: 30.0)
        ]
    )
    EditSplitExpenseView(editRequest: $sampleRequest, viewModel: ExpenseViewModel(), groupId: 1).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
