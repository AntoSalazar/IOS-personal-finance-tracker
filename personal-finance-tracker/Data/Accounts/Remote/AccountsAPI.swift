import Foundation

final class AccountsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getAll() async throws -> AccountsResponseDTO {
        try await client.request(endpoint: "accounts")
    }

    func getById(_ id: String) async throws -> AccountDTO {
        try await client.request(endpoint: "accounts/\(id)")
    }

    func create(request: CreateAccountRequestDTO) async throws -> AccountDTO {
        try await client.post(endpoint: "accounts", body: request)
    }

    func update(id: String, request: UpdateAccountRequestDTO) async throws -> AccountDTO {
        try await client.put(endpoint: "accounts/\(id)", body: request)
    }

    func delete(id: String) async throws {
        try await client.delete(endpoint: "accounts/\(id)")
    }
}
