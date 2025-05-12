import SwiftUI

struct ExpenseListView: View {
    @StateObject var expenseViewModel = ExpenseViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    let groupId: Int
    @State private var showAddExpenseSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if expenseViewModel.expenses.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No expenses yet")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Text("Start by adding a new expense.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            NavigationLink(destination: UserDebtsView(expenseViewModel: expenseViewModel, groupId: groupId)) {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("View Debts")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }

                            ForEach(expenseViewModel.expenses, id: \.id) { expense in
                                NavigationLink(destination: ExpenseView(expense: expense, expenseViewModel: expenseViewModel)) {
                                    ExpenseRowView(expense: expense)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddExpenseSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showAddExpenseSheet) {
                NewExpenseView(expenseViewModel: expenseViewModel, groupId: groupId)
            }
            .task {
                await expenseViewModel.loadExpenses(forGroup: groupId, user: authViewModel.user)
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: ExpenseResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(expense.name)
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", expense.amount))
                    .bold()
                    .foregroundColor(.green)
            }

            if !expense.description.isEmpty {
                Text(expense.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Date: \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    ExpenseListView(groupId: 87).environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
    
}
