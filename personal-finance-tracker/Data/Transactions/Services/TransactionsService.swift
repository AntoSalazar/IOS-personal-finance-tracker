import Foundation

final class TransactionsService: TransactionsRepository {
    private let api: TransactionsAPI

    init(api: TransactionsAPI) {
        self.api = api
    }

    func getAll(accountId: String?, categoryId: String?, type: TransactionType?, startDate: Date?, endDate: Date?) async throws -> [Transaction] {
        let response = try await api.getAll(
            accountId: accountId,
            categoryId: categoryId,
            type: type?.rawValue,
            startDate: startDate,
            endDate: endDate
        )
        return response.transactions.map { $0.toDomain() }
    }

    func create(accountId: String, amount: Double, type: TransactionType, description: String, reason: String?, categoryId: String?, date: Date) async throws -> Transaction {
        let request = CreateTransactionRequestDTO(
            accountId: accountId,
            amount: amount,
            type: type.rawValue,
            description: description,
            reason: reason,
            categoryId: categoryId,
            date: date
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func createTransfer(fromAccountId: String, toAccountId: String, amount: Double, description: String, date: Date) async throws {
        let request = CreateTransferRequestDTO(
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            amount: amount,
            description: description,
            date: date
        )
        try await api.createTransfer(request: request)
    }
}
