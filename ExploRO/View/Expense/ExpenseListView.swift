import SwiftUI

struct ExpenseListView: View {
    @StateObject var expenseViewModel = ExpenseViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    let groupId: Int
    @State private var showAddExpenseSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if expenseViewModel.expenses.isEmpty {
                    Text("No expenses found.")
                        .foregroundColor(.gray)
                } else {
                    List(expenseViewModel.expenses, id: \.id) { expense in
                        NavigationLink(destination: ExpenseView(expense: expense, expenseViewModel: expenseViewModel)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(expense.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(String(format: "$%.2f", expense.amount))
                                        .bold()
                                }
                                Text(expense.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Date: \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddExpenseSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showAddExpenseSheet) {
                        NewExpenseView(expenseViewModel: expenseViewModel, groupId: groupId)
                    }
                }
            }
            
            
        }
        .task {
            await expenseViewModel.loadExpenses(forGroup: groupId, user:authViewModel.user)
            
        }
    }
}


#Preview {
    ExpenseListView(groupId: 45).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    
}
