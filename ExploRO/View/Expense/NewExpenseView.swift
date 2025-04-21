import SwiftUI

struct NewExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @StateObject private var groupViewModel = GroupViewModel()
    
    let groupId: Int
    
    @State private var request = NewExpenseRequest(
        name: "",
        groupId: 0, // Will assign this properly in .onAppear
        payerId: "",
        date: Date(),
        amount: 0.0,
        description: "",
        type: "",
        debtors: []
    )
    
    @State private var stringAmount = ""
    @State private var stringPayerId = ""
    @State private var goToSplitExpense = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Info")) {
                    TextField("Name", text: $request.name)
                    TextField("Amount", text: $stringAmount)
                        .keyboardType(.decimalPad)
                        .onChange(of: stringAmount) {
                            request.amount = Double(stringAmount) ?? 0.0
                        }
                    
                    TextField("Description", text: $request.description)
                    
                    Picker("Type", selection: $request.type) {
                        Text("None").tag("None")
                        Text("Split Equally").tag("Split Equally")
                        Text("Split Manually").tag("Split Manually")
                    }
                    
                    Picker("Payer", selection: $request.payerId) {
                        Text("None").tag("None")
                        ForEach(groupViewModel.groupMembers, id: \.userId) { member in
                            Text(member.userName.isEmpty ? member.userEmail : member.userName)
                                        .tag(member.userId)
                            
                        }
                    }
                    
                    
                    DatePicker("Date", selection: $request.date, displayedComponents: .date)
                }
                
                NavigationLink{
                    SplitExpenseView(expenseViewModel: expenseViewModel, request: request, members: groupViewModel.groupMembers)
                }label: {
                    Text("Next")
                        .foregroundStyle(Color.blue)
                }
                .disabled(request.name.isEmpty ||
                          request.amount <= 0 ||
                          request.payerId.isEmpty ||
                          request.type.elementsEqual("None") ||
                          request.payerId.elementsEqual("None"))
            }
            .navigationTitle("New Expense")
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
}

#Preview {
    NewExpenseView(expenseViewModel: ExpenseViewModel(), groupId: 45).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
