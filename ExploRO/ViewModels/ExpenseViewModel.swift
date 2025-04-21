import Foundation
import FirebaseAuth

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseResponse] = []
    @Published var errorMessage: String?
    
    private let expenseService: ExpenseServiceProtocol
    
    init(expenseService: ExpenseServiceProtocol = ExpenseService()) {
        self.expenseService = expenseService
    }
    
    func loadExpenses(forGroup groupId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedExpenses = try await expenseService.fetchExpenses(forGroup: groupId, idToken: idToken)
            self.expenses = fetchedExpenses
        } catch {
            self.errorMessage = "Failed to load expenses. Please try again."
        }
    }
    
    func saveExpensesEqually(expense: NewExpenseRequest, selectedUserIds: Set<String>, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            
            let totalUsers = selectedUserIds.count
            guard totalUsers > 0 else {
                errorMessage = "No users selected"
                return
            }
            
            let splitAmount = expense.amount / Double(totalUsers)
            let roundedSplitAmount = (splitAmount * 100).rounded() / 100  // round to 2 decimals
            
            let debtors = selectedUserIds.map { userId in
                DebtRequest(userId: userId, amountToPay: roundedSplitAmount)
            }
            
            let finalExpense = NewExpenseRequest(
                name: expense.name,
                groupId: expense.groupId,
                payerId: expense.payerId,
                date: expense.date,
                amount: expense.amount,
                description: expense.description,
                type: expense.type,
                debtors: debtors
            )
            
            //try await expenseService.saveExpense(expense: finalExpense, idToken: idToken)
            print(finalExpense)
        } catch {
            errorMessage = "Failed to save expense: \(error.localizedDescription)"
        }
    }
    
    func saveExpensesManually(expense: NewExpenseRequest, manualAmounts: [String: String], user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
    }
}
