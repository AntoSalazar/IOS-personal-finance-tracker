import Foundation

protocol SubscriptionsRepository {
    func getAll(status: SubscriptionStatus?, accountId: String?) async throws -> [Subscription]
    func getById(_ id: String) async throws -> Subscription
    func create(name: String, amount: Double, frequency: SubscriptionFrequency, nextBillingDate: Date, accountId: String?, categoryId: String?, notes: String?) async throws -> Subscription
    func update(id: String, name: String?, amount: Double?, frequency: SubscriptionFrequency?, nextBillingDate: Date?, accountId: String?, categoryId: String?, status: SubscriptionStatus?, notes: String?) async throws -> Subscription
    func delete(id: String) async throws
    func process(id: String) async throws
    func processDue() async throws
    func getSummary() async throws -> SubscriptionSummary
}
