import Foundation
import FirebaseAuth

@MainActor
class DebtViewModel: ObservableObject {
    @Published var debts: [DebtDetailResponse] = []
    @Published var errorMessage: String?
    @Published var showAlert = false
    
    private let debtService: DebtServiceProtocol
    init(debtService: DebtServiceProtocol = DebtService()) {
        self.debtService = debtService
    }
    
    func fetchDebts(forGroup groupId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            let idToken = try await user.getIDToken()
            let fetchedDebts = try await debtService.fetchDebts(groupId: groupId, idToken: idToken)
            self.debts = fetchedDebts
        }catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func deleteDebt(groupId: Int, debtId: Int, user: User?) async {
        guard let user = user else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            let idToken = try await user.getIDToken()
            try await debtService.deleteDebt(debtId: debtId, idToken: idToken)
            await fetchDebts(forGroup: groupId, user: user)
        }catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

