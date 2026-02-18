import Foundation

enum CategoryType: String, Codable, CaseIterable, Identifiable {
    case expense = "EXPENSE"
    case income = "INCOME"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
}
