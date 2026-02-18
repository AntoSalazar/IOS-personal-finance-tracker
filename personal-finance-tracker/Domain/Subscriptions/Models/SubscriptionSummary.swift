import Foundation

struct SubscriptionSummary: Equatable {
    let totalSubscriptions: Int
    let activeSubscriptions: Int
    let pausedSubscriptions: Int
    let cancelledSubscriptions: Int
    let totalMonthlyAmount: Double
    let nextBillingDate: Date?

    // Convenience accessors
    var totalMonthly: Double { totalMonthlyAmount }
    var totalYearly: Double { totalMonthlyAmount * 12 }
    var count: Int { activeSubscriptions }
}
