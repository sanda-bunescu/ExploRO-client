import SwiftUI

struct UserDebtsView: View {
    @StateObject private var viewModel = DebtViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel1
    @ObservedObject var expenseViewModel: ExpenseViewModel
    let groupId: Int
    @State private var debtToDelete: DebtDetailResponse?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.debts.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green.opacity(0.6))
                        Text("No Debts")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("You're all settled up!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.debts, id: \.id) { debt in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("You owe \(debt.payerName)")
                                        .font(.headline)
                                    Text("💰 $\(debt.amountToPay, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    debtToDelete = debt
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Your Debts")
            .task {
                await viewModel.fetchDebts(forGroup: groupId, user: authViewModel.user)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Settle Up"),
                    message: Text("Do you want to settle your debt to \(debtToDelete?.payerName ?? "user")?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let debtToDelete = debtToDelete {
                            Task {
                                await viewModel.deleteDebt(groupId: groupId, debtId: debtToDelete.id, user: authViewModel.user)
                                await expenseViewModel.loadExpenses(forGroup: groupId, user: authViewModel.user)
                            }
                        }
                    },
                    secondaryButton: .cancel {
                        debtToDelete = nil
                    }
                )
            }
        }
    }
}


#Preview {
    UserDebtsView(expenseViewModel: ExpenseViewModel(), groupId: 87)
        .environmentObject(AuthenticationViewModel1(firebaseService: FirebaseAuthentication(), authService: AuthService()))
}
