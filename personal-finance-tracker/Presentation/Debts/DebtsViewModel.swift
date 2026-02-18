import Foundation
import Observation

@Observable
@MainActor
final class DebtsViewModel {
    private(set) var debts: [Debt] = []
    private(set) var summary: DebtSummary?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var showAddDebt = false
    var showPaidFilter = false

    private let repository: DebtsRepository

    init(repository: DebtsRepository) {
        self.repository = repository
    }

    func loadDebts() async {
        isLoading = true
        errorMessage = nil

        do {
            let isPaid: Bool? = showPaidFilter ? nil : false
            async let debtsResult = repository.getAll(isPaid: isPaid)
            async let summaryResult = repository.getSummary()
            debts = try await debtsResult
            summary = try await summaryResult
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load debts: \(error)", category: .network)
        }

        isLoading = false
    }

    func createDebt(personName: String, amount: Double, description: String? = nil, dueDate: Date? = nil, notes: String? = nil) async -> Bool {
        do {
            _ = try await repository.create(
                personName: personName,
                amount: amount,
                description: description,
                dueDate: dueDate,
                notes: notes
            )
            await loadDebts()
            return true
        } catch {
            Logger.error("Failed to create debt: \(error)", category: .network)
            return false
        }
    }

    func deleteDebt(id: String) async -> Bool {
        do {
            try await repository.delete(id: id)
            await loadDebts()
            return true
        } catch {
            Logger.error("Failed to delete debt: \(error)", category: .network)
            return false
        }
    }

    func markAsPaid(id: String, accountId: String, categoryId: String) async -> Bool {
        do {
            _ = try await repository.markAsPaid(id: id, accountId: accountId, categoryId: categoryId)
            await loadDebts()
            return true
        } catch {
            Logger.error("Failed to mark debt as paid: \(error)", category: .network)
            return false
        }
    }
}
