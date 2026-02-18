import Foundation

struct DebtSummary: Equatable {
    let totalDebts: Int
    let totalAmount: Double
    let paidDebts: Int
    let paidAmount: Double
    let unpaidDebts: Int
    let unpaidAmount: Double

    // Convenience accessors for views
    var totalOwed: Double { unpaidAmount }
    var totalPaid: Double { paidAmount }
    var count: Int { totalDebts }
}
