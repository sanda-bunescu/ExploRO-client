import SwiftUI

struct NewExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @StateObject private var groupViewModel = GroupViewModel()
    
    let groupId: Int
    
    @State private var request = NewExpenseRequest(
        name: "",
        groupId: 0,
        payerId: "",
        date: Date(),
        amount: 0.0,
        description: "",
        type: "",
        debtors: []
    )
    
    @State private var stringAmount = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create New Expense")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Group {
                        CustomTextField(title: "Name", text: $request.name)
                        
                        CustomTextField(title: "Amount", text: $stringAmount, keyboardType: .decimalPad)
                            .onChange(of: stringAmount) {
                                let formatter = NumberFormatter()
                                formatter.locale = Locale.current
                                formatter.numberStyle = .decimal
                                if let number = formatter.number(from: stringAmount) {
                                    request.amount = number.doubleValue
                                } else {
                                    request.amount = 0.0
                                }
                            }

                        
                        CustomTextField(title: "Description", text: $request.description)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Type")
                            .font(.headline)
                        Picker("Type", selection: $request.type) {
                            Text("None").tag("None")
                            Text("Split Equally").tag("Split Equally")
                            Text("Split Manually").tag("Split Manually")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Payer")
                            .font(.headline)
                        Menu {
                            ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                                Button {
                                    request.payerId = member.userId
                                } label: {
                                    Text(member.userName.isEmpty ? member.userEmail : member.userName)
                                }
                            }
                        } label: {
                            HStack {
                                Text(displayPayerName())
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                    
                    DatePicker("Date", selection: $request.date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    NavigationLink {
                        SplitExpenseView(
                            expenseViewModel: expenseViewModel,
                            request: request,
                            members: groupViewModel.groupMembers
                        )
                    } label: {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isNextDisabled ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isNextDisabled)
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
            .onAppear {
                request.groupId = groupId
                Task {
                    await groupViewModel.fetchUsersByGroupId(groupId: groupId, user: authViewModel.user)
                }
            }
        }
    }
    
    private var isNextDisabled: Bool {
        request.name.isEmpty ||
        request.amount <= 0 ||
        request.payerId.isEmpty ||
        request.type == "None"
    }
    
    private func displayPayerName() -> String {
        if let payer = groupViewModel.groupMembers.first(where: { $0.userId == request.payerId }) {
            return payer.userName.isEmpty ? payer.userEmail : payer.userName
        }
        return "Select Payer"
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}


#Preview {
    NewExpenseView(expenseViewModel: ExpenseViewModel(), groupId: 87).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
