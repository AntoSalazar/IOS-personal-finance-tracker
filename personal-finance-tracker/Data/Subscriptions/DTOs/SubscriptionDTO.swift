import Foundation

struct SubscriptionDTO: Codable {
    let id: String
    let name: String
    let amount: Double
    let frequency: String
    let nextBillingDate: Date
    let accountId: String?
    let categoryId: String?
    let status: String
    let notes: String?

    func toDomain() -> Subscription {
        Subscription(
            id: id,
            name: name,
            amount: amount,
            frequency: SubscriptionFrequency(rawValue: frequency) ?? .monthly,
            nextBillingDate: nextBillingDate,
            accountId: accountId,
            categoryId: categoryId,
            status: SubscriptionStatus(rawValue: status) ?? .active,
            notes: notes
        )
    }
}

struct SubscriptionsResponseDTO: Codable {
    let subscriptions: [SubscriptionDTO]
}

struct SubscriptionSummaryDTO: Codable {
    let totalSubscriptions: Int?
    let activeSubscriptions: Int?
    let pausedSubscriptions: Int?
    let cancelledSubscriptions: Int?
    let totalMonthlyAmount: Double?
    let nextBillingDate: Date?

    func toDomain() -> SubscriptionSummary {
        SubscriptionSummary(
            totalSubscriptions: totalSubscriptions ?? 0,
            activeSubscriptions: activeSubscriptions ?? 0,
            pausedSubscriptions: pausedSubscriptions ?? 0,
            cancelledSubscriptions: cancelledSubscriptions ?? 0,
            totalMonthlyAmount: totalMonthlyAmount ?? 0,
            nextBillingDate: nextBillingDate
        )
    }
}

struct CreateSubscriptionRequestDTO: Encodable {
    let name: String
    let amount: Double
    let frequency: String
    let nextBillingDate: Date
    let accountId: String?
    let categoryId: String?
    let notes: String?
}

struct UpdateSubscriptionRequestDTO: Encodable {
    let name: String?
    let amount: Double?
    let frequency: String?
    let nextBillingDate: Date?
    let accountId: String?
    let categoryId: String?
    let status: String?
    let notes: String?
}
