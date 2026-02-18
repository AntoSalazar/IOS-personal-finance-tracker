import Foundation
import Observation

@Observable
@MainActor
final class SubscriptionsViewModel {
    private(set) var subscriptions: [Subscription] = []
    private(set) var summary: SubscriptionSummary?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var showAddSubscription = false
    var selectedStatusFilter: SubscriptionStatus?

    private let repository: SubscriptionsRepository

    init(repository: SubscriptionsRepository) {
        self.repository = repository
    }

    func loadSubscriptions() async {
        isLoading = true
        errorMessage = nil

        do {
            async let subsResult = repository.getAll(status: selectedStatusFilter, accountId: nil)
            async let summaryResult = repository.getSummary()
            subscriptions = try await subsResult
            summary = try await summaryResult
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load subscriptions: \(error)", category: .network)
        }

        isLoading = false
    }

    func createSubscription(name: String, amount: Double, frequency: SubscriptionFrequency, nextBillingDate: Date, accountId: String? = nil, categoryId: String? = nil, notes: String? = nil) async -> Bool {
        do {
            _ = try await repository.create(
                name: name,
                amount: amount,
                frequency: frequency,
                nextBillingDate: nextBillingDate,
                accountId: accountId,
                categoryId: categoryId,
                notes: notes
            )
            await loadSubscriptions()
            return true
        } catch {
            Logger.error("Failed to create subscription: \(error)", category: .network)
            return false
        }
    }

    func updateSubscription(id: String, name: String? = nil, amount: Double? = nil, frequency: SubscriptionFrequency? = nil, status: SubscriptionStatus? = nil, notes: String? = nil) async -> Bool {
        do {
            _ = try await repository.update(
                id: id,
                name: name,
                amount: amount,
                frequency: frequency,
                nextBillingDate: nil,
                accountId: nil,
                categoryId: nil,
                status: status,
                notes: notes
            )
            await loadSubscriptions()
            return true
        } catch {
            Logger.error("Failed to update subscription: \(error)", category: .network)
            return false
        }
    }

    func deleteSubscription(id: String) async -> Bool {
        do {
            try await repository.delete(id: id)
            await loadSubscriptions()
            return true
        } catch {
            Logger.error("Failed to delete subscription: \(error)", category: .network)
            return false
        }
    }

    func processSubscription(id: String) async -> Bool {
        do {
            try await repository.process(id: id)
            await loadSubscriptions()
            return true
        } catch {
            Logger.error("Failed to process subscription: \(error)", category: .network)
            return false
        }
    }
}
