import Foundation

struct Subscription: Identifiable, Equatable {
    let id: String
    let name: String
    let amount: Double
    let frequency: SubscriptionFrequency
    let nextBillingDate: Date
    let accountId: String?
    let categoryId: String?
    let status: SubscriptionStatus
    let notes: String?
}
