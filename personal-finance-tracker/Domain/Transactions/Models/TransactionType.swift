import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case expense = "EXPENSE"
    case income = "INCOME"
    case transfer = "TRANSFER"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .transfer: return "Transfer"
        }
    }

    var icon: String {
        switch self {
        case .expense: return "arrow.up.circle.fill"
        case .income: return "arrow.down.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }
}
