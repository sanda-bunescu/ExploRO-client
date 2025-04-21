import SwiftUI

struct EditSplitExpenseView: View {
    @StateObject private var groupViewModel = GroupViewModel()
    @Binding var editRequest: EditExpenseRequest
    let members: [GroupUserResponse] = [
        .init(userId: "1", userName: "Alice", userEmail: "alice@email.com"),
        .init(userId: "2", userName: "Bob", userEmail: "bob@email.com"),
        .init(userId: "3", userName: "Charlie", userEmail: "charlie@email.com")
    ]
    
    @State private var selectedUserIds: Set<String> = []
    @State private var manualAmounts: [String: String] = [:]
    var body: some View {
        if editRequest.type == "Split Equally" {
            Section(header: Text("Select Members to Split With")) {
                ForEach(members, id: \.userId) { member in
                    Toggle(member.userName, isOn: Binding(
                        get: {
                            selectedUserIds.contains(member.userId) ||
                            editRequest.debtors.contains { $0.userId == member.userId }
                        },
                        set: { isOn in
                            if isOn {
                                selectedUserIds.insert(member.userId)
                                if !(editRequest.debtors.contains(where: { $0.userId == member.userId })) {
                                    let debt = DebtResponse(id: UUID().hashValue, userId: member.userId, userName: member.userName, amountToPay: 0)
                                    editRequest.debtors.append(debt)
                                }
                            } else {
                                selectedUserIds.remove(member.userId)
                                editRequest.debtors.removeAll { $0.userId == member.userId }
                            }
                        }
                    ))
                }
            }
        }else if editRequest.type == "Split Manually" {
            Section(header: Text("Assign Manual Amounts")) {
                ForEach(members, id: \.userId) { member in
                    HStack {
                        Text(member.userName)
                        Spacer()
                        let userId = member.userId
                        let currentAmountString = {
                            if let debt = editRequest.debtors.first(where: { $0.userId == userId }) {
                                return String(format: "%.2f", debt.amountToPay)
                            }
                            return manualAmounts[userId] ?? ""
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
                                        let newDebt = DebtResponse(id: UUID().hashValue, userId: userId, userName: member.userName, amountToPay: amount)
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
            Button{
                print(editRequest)
            }label:{
                Text("Save")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
            DebtResponse(id: 1, userId: "1", userName: "Alice", amountToPay: 30.0),
            DebtResponse(id: 2, userId: "2", userName: "Bob", amountToPay: 30.0)
        ]
    )
    EditSplitExpenseView(editRequest: $sampleRequest)
}
