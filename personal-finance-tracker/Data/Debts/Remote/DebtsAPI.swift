import Foundation

final class DebtsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getAll(isPaid: Bool? = nil) async throws -> DebtsResponseDTO {
        var queryItems: [URLQueryItem]? = nil
        if let isPaid {
            queryItems = [URLQueryItem(name: "isPaid", value: String(isPaid))]
        }
        return try await client.request(endpoint: "debts", queryItems: queryItems)
    }

    func getById(_ id: String) async throws -> DebtDTO {
        try await client.request(endpoint: "debts/\(id)")
    }

    func create(request: CreateDebtRequestDTO) async throws -> DebtDTO {
        try await client.post(endpoint: "debts", body: request)
    }

    func update(id: String, request: UpdateDebtRequestDTO) async throws -> DebtDTO {
        try await client.put(endpoint: "debts/\(id)", body: request)
    }

    func delete(id: String) async throws {
        try await client.delete(endpoint: "debts/\(id)")
    }

    func markAsPaid(id: String, accountId: String, categoryId: String) async throws -> DebtDTO {
        let request = MarkDebtAsPaidRequestDTO(accountId: accountId, categoryId: categoryId, paidDate: nil)
        return try await client.post(endpoint: "debts/\(id)/pay", body: request)
    }

    func getSummary() async throws -> DebtSummaryDTO {
        try await client.request(endpoint: "debts/summary")
    }
}
