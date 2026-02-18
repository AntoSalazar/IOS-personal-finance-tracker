import Foundation
import Observation

@Observable
@MainActor
final class AccountsViewModel {
    private(set) var state: AccountsState = .idle
    var showAddAccount = false
    var accountToDelete: Account?

    private let repository: AccountsRepository

    init(repository: AccountsRepository) {
        self.repository = repository
    }

    func loadAccounts() async {
        state = .loading

        do {
            let result = try await repository.getAll()
            state = .success(result.accounts, totalBalance: result.totalBalance)
        } catch {
            state = .error(error.localizedDescription)
            Logger.error("Failed to load accounts: \(error)", category: .network)
        }
    }

    func createAccount(name: String, type: AccountType, balance: Double, currency: String = "MXN", description: String? = nil) async -> Bool {
        do {
            _ = try await repository.create(
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                description: description
            )
            await loadAccounts()
            return true
        } catch {
            Logger.error("Failed to create account: \(error)", category: .network)
            return false
        }
    }

    func updateAccount(id: String, name: String? = nil, type: AccountType? = nil, balance: Double? = nil, currency: String? = nil, description: String? = nil, isActive: Bool? = nil) async -> Bool {
        do {
            _ = try await repository.update(
                id: id,
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                description: description,
                isActive: isActive
            )
            await loadAccounts()
            return true
        } catch {
            Logger.error("Failed to update account: \(error)", category: .network)
            return false
        }
    }

    func deleteAccount(id: String) async -> Bool {
        do {
            try await repository.delete(id: id)
            await loadAccounts()
            return true
        } catch {
            Logger.error("Failed to delete account: \(error)", category: .network)
            return false
        }
    }
}
