import Foundation
import Observation

@Observable
@MainActor
final class TransactionsViewModel {
    private(set) var state: TransactionsState = .idle
    var showAddTransaction = false
    var showTransfer = false
    var searchText = ""
    var selectedTypeFilter: TransactionType?
    var selectedAccountId: String?
    var selectedCategoryId: String?

    private let repository: TransactionsRepository

    init(repository: TransactionsRepository) {
        self.repository = repository
    }

    var filteredTransactions: [Transaction] {
        let transactions = state.transactions
        if searchText.isEmpty { return transactions }
        return transactions.filter {
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.name.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.account?.name.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    func loadTransactions() async {
        state = .loading

        do {
            let transactions = try await repository.getAll(
                accountId: selectedAccountId,
                categoryId: selectedCategoryId,
                type: selectedTypeFilter,
                startDate: nil,
                endDate: nil
            )
            state = .success(transactions)
        } catch {
            state = .error(error.localizedDescription)
            Logger.error("Failed to load transactions: \(error)", category: .network)
        }
    }

    func createTransaction(accountId: String, amount: Double, type: TransactionType, description: String, reason: String? = nil, categoryId: String? = nil, date: Date = Date()) async -> Bool {
        do {
            _ = try await repository.create(
                accountId: accountId,
                amount: amount,
                type: type,
                description: description,
                reason: reason,
                categoryId: categoryId,
                date: date
            )
            await loadTransactions()
            return true
        } catch {
            Logger.error("Failed to create transaction: \(error)", category: .network)
            return false
        }
    }

    func createTransfer(fromAccountId: String, toAccountId: String, amount: Double, description: String, date: Date = Date()) async -> Bool {
        do {
            try await repository.createTransfer(
                fromAccountId: fromAccountId,
                toAccountId: toAccountId,
                amount: amount,
                description: description,
                date: date
            )
            await loadTransactions()
            return true
        } catch {
            Logger.error("Failed to create transfer: \(error)", category: .network)
            return false
        }
    }

    func applyFilter(type: TransactionType?) {
        selectedTypeFilter = type
        Task { await loadTransactions() }
    }
}
