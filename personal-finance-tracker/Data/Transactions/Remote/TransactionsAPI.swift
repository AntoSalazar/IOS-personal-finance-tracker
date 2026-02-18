import Foundation

final class TransactionsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getAll(accountId: String? = nil, categoryId: String? = nil, type: String? = nil, startDate: Date? = nil, endDate: Date? = nil) async throws -> TransactionsResponseDTO {
        var queryItems: [URLQueryItem] = []
        if let accountId { queryItems.append(URLQueryItem(name: "accountId", value: accountId)) }
        if let categoryId { queryItems.append(URLQueryItem(name: "categoryId", value: categoryId)) }
        if let type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let startDate { queryItems.append(URLQueryItem(name: "startDate", value: ISO8601DateFormatter().string(from: startDate))) }
        if let endDate { queryItems.append(URLQueryItem(name: "endDate", value: ISO8601DateFormatter().string(from: endDate))) }
        return try await client.request(endpoint: "transactions", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    func create(request: CreateTransactionRequestDTO) async throws -> TransactionDTO {
        try await client.post(endpoint: "transactions", body: request)
    }

    func createTransfer(request: CreateTransferRequestDTO) async throws {
        try await client.post(endpoint: "transfers", body: request)
    }
}
