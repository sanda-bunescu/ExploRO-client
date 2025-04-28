import SwiftUI

struct UserDebtsView: View {
    @StateObject private var viewModel = DebtViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var expenseViewModel: ExpenseViewModel  
    let groupId: Int
    
    var body: some View {
        NavigationView {
            List(viewModel.debts, id: \.id) { debt in
                HStack{
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You owe user: \( debt.payerName)")
                            .font(.headline)
                        Text("💰 Amount to Pay: \(debt.amountToPay, specifier: "%.2f")")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button{
                        Task{
                            await viewModel.deleteDebt(groupId: groupId, debtId: debt.id, user: authViewModel.user)
                            await expenseViewModel.loadExpenses(forGroup: groupId, user: authViewModel.user)
                                                
                        }
                    }label:{
                        Image(systemName: "trash")
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Your Debts")
            .task {
                await viewModel.fetchDebts(forGroup: groupId, user: authViewModel.user)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    UserDebtsView(expenseViewModel: ExpenseViewModel(), groupId: 1)
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
