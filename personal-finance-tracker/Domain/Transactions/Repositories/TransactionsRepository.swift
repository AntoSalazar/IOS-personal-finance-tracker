import Foundation

protocol TransactionsRepository {
    func getAll(accountId: String?, categoryId: String?, type: TransactionType?, startDate: Date?, endDate: Date?) async throws -> [Transaction]
    func create(accountId: String, amount: Double, type: TransactionType, description: String, reason: String?, categoryId: String?, date: Date) async throws -> Transaction
    func createTransfer(fromAccountId: String, toAccountId: String, amount: Double, description: String, date: Date) async throws
}
