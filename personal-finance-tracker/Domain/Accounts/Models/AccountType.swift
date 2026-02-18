import Foundation

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case checking = "CHECKING"
    case savings = "SAVINGS"
    case creditCard = "CREDIT_CARD"
    case investment = "INVESTMENT"
    case cash = "CASH"
    case other = "OTHER"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .creditCard: return "Credit Card"
        case .investment: return "Investment"
        case .cash: return "Cash"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .checking: return "building.columns.fill"
        case .savings: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .cash: return "dollarsign.circle.fill"
        case .other: return "wallet.pass.fill"
        }
    }
}
