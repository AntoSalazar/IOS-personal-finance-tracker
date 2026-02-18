import Foundation

protocol DebtsRepository {
    func getAll(isPaid: Bool?) async throws -> [Debt]
    func getById(_ id: String) async throws -> Debt
    func create(personName: String, amount: Double, description: String?, dueDate: Date?, notes: String?) async throws -> Debt
    func update(id: String, personName: String?, amount: Double?, description: String?, dueDate: Date?, notes: String?) async throws -> Debt
    func delete(id: String) async throws
    func markAsPaid(id: String, accountId: String, categoryId: String) async throws -> Debt
    func getSummary() async throws -> DebtSummary
}
