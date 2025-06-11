import Foundation
import FirebaseAuth

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseResponse] = []
    @Published var errorMessage: String?
    @Published var showAlert = false
    
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
            try await expenseService.saveExpense(finalExpense, idToken: idToken)
            await loadExpenses(forGroup: expense.groupId, user: user)
        } catch {
            errorMessage = "Failed to save expense: \(error.localizedDescription)"
        }
    }
    
    func saveExpensesManually(expense: NewExpenseRequest, manualAmounts: [String: String], user: User?) async -> Bool {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return false
        }
        
        do {
            let idToken = try await user.getIDToken()
            
            // Convert values to Doubles and filter out invalid ones
            let parsedDebtors: [DebtRequest] = manualAmounts.compactMap { key, value in
                if let amount = Double(value.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 {
                    return DebtRequest(userId: key, amountToPay: (amount * 100).rounded() / 100)
                } else {
                    return nil
                }
            }
            
            let total = parsedDebtors.reduce(0.0) { $0 + $1.amountToPay }
            let totalRounded = (total * 100).rounded() / 100
            
            guard totalRounded == expense.amount else {
                errorMessage = "Manual amounts do not match the total expense."
                showAlert = true
                return false
            }
            
            let finalExpense = NewExpenseRequest(
                name: expense.name,
                groupId: expense.groupId,
                payerId: expense.payerId,
                date: expense.date,
                amount: expense.amount,
                description: expense.description,
                type: expense.type,
                debtors: parsedDebtors
            )
            try await expenseService.saveExpense(finalExpense, idToken: idToken)
            await loadExpenses(forGroup: expense.groupId, user: user)
            return true
            
        } catch {
            errorMessage = "Failed to save expense: \(error.localizedDescription)"
            showAlert = true
            return false
        }
    }
    func deleteExpense(expense: ExpenseResponse, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            try await expenseService.deleteExpense(expenseId: expense.id, idToken: idToken)
            await loadExpenses(forGroup: expense.groupId, user: user)
        } catch {
            self.errorMessage = "Failed to load expenses. Please try again."
        }
    }
    
    func editExpense(expense: EditExpenseRequest, user: User?, groupId: Int) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do{
            let idToken = try await user.getIDToken()
            try await self.expenseService.editExpense(expense: expense, idToken: idToken)
            await loadExpenses(forGroup: groupId, user: user)
        } catch{
            self.errorMessage = "Failed to edit expenses. Please try again."
        }
    }
    
    
    func updateSplitEquallyDebtors(selectedUserIds: Set<String>, totalAmount: Double, editRequest: inout EditExpenseRequest) {
        let count = selectedUserIds.count
        guard count > 0 else {
            editRequest.debtors = []
            return
        }
        
        let splitAmount = totalAmount / Double(count)
        editRequest.debtors = selectedUserIds.map {
            DebtRequest(userId: $0, amountToPay: splitAmount)
        }
    }
    
}

