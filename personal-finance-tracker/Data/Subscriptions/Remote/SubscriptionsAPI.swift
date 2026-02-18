import Foundation

final class SubscriptionsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getAll(status: String? = nil, accountId: String? = nil) async throws -> SubscriptionsResponseDTO {
        var queryItems: [URLQueryItem] = []
        if let status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if let accountId { queryItems.append(URLQueryItem(name: "accountId", value: accountId)) }
        return try await client.request(endpoint: "subscriptions", queryItems: queryItems.isEmpty ? nil : queryItems)
    }

    func getById(_ id: String) async throws -> SubscriptionDTO {
        try await client.request(endpoint: "subscriptions/\(id)")
    }

    func create(request: CreateSubscriptionRequestDTO) async throws -> SubscriptionDTO {
        try await client.post(endpoint: "subscriptions", body: request)
    }

    func update(id: String, request: UpdateSubscriptionRequestDTO) async throws -> SubscriptionDTO {
        try await client.put(endpoint: "subscriptions/\(id)", body: request)
    }

    func delete(id: String) async throws {
        try await client.delete(endpoint: "subscriptions/\(id)")
    }

    func process(id: String) async throws {
        try await client.post(endpoint: "subscriptions/\(id)/process")
    }

    func processDue() async throws {
        try await client.post(endpoint: "subscriptions/process-due")
    }

    func getSummary() async throws -> SubscriptionSummaryDTO {
        try await client.request(endpoint: "subscriptions/summary")
    }
}
