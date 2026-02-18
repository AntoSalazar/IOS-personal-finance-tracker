import Foundation

final class SubscriptionsService: SubscriptionsRepository {
    private let api: SubscriptionsAPI

    init(api: SubscriptionsAPI) {
        self.api = api
    }

    func getAll(status: SubscriptionStatus?, accountId: String?) async throws -> [Subscription] {
        let response = try await api.getAll(status: status?.rawValue, accountId: accountId)
        return response.subscriptions.map { $0.toDomain() }
    }

    func getById(_ id: String) async throws -> Subscription {
        let dto = try await api.getById(id)
        return dto.toDomain()
    }

    func create(name: String, amount: Double, frequency: SubscriptionFrequency, nextBillingDate: Date, accountId: String?, categoryId: String?, notes: String?) async throws -> Subscription {
        let request = CreateSubscriptionRequestDTO(
            name: name,
            amount: amount,
            frequency: frequency.rawValue,
            nextBillingDate: nextBillingDate,
            accountId: accountId,
            categoryId: categoryId,
            notes: notes
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func update(id: String, name: String?, amount: Double?, frequency: SubscriptionFrequency?, nextBillingDate: Date?, accountId: String?, categoryId: String?, status: SubscriptionStatus?, notes: String?) async throws -> Subscription {
        let request = UpdateSubscriptionRequestDTO(
            name: name,
            amount: amount,
            frequency: frequency?.rawValue,
            nextBillingDate: nextBillingDate,
            accountId: accountId,
            categoryId: categoryId,
            status: status?.rawValue,
            notes: notes
        )
        let dto = try await api.update(id: id, request: request)
        return dto.toDomain()
    }

    func delete(id: String) async throws {
        try await api.delete(id: id)
    }

    func process(id: String) async throws {
        try await api.process(id: id)
    }

    func processDue() async throws {
        try await api.processDue()
    }

    func getSummary() async throws -> SubscriptionSummary {
        let dto = try await api.getSummary()
        return dto.toDomain()
    }
}
