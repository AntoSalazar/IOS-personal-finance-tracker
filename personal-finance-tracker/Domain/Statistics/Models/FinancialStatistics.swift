import Foundation

struct FinancialStatistics: Equatable {
    let period: String
    let dateRange: DateRange?
    let summary: StatsSummary
    let categoryBreakdown: [CategoryBreakdownItem]
    let incomeCategoryBreakdown: [CategoryBreakdownItem]
    let monthlyTrends: [MonthlyTrend]
    let accountBalances: [AccountBalance]
    let dailyTrend: [DailyTrendItem]
    let topSpending: [TopSpendingItem]

    // Convenience accessors
    var income: Double { summary.totalIncome }
    var expenses: Double { summary.totalExpenses }
    var balance: Double { summary.netIncome }
    var netWorth: Double { summary.netWorth }
}

struct DateRange: Equatable {
    let start: Date
    let end: Date
}

struct StatsSummary: Equatable {
    let totalIncome: Double
    let totalExpenses: Double
    let netIncome: Double
    let savingsRate: Double
    let netWorth: Double
    let transactionCount: Int
    let avgExpenseAmount: Double
    let avgIncomeAmount: Double
}

struct CategoryBreakdownItem: Equatable, Identifiable {
    var id: String { name }
    let name: String
    let amount: Double
    let count: Int
    let color: String?
}

struct MonthlyTrend: Equatable, Identifiable {
    var id: String { month }
    let month: String
    let income: Double
    let expenses: Double
    let net: Double
}

struct AccountBalance: Equatable, Identifiable {
    var id: String { name }
    let name: String
    let balance: Double
    let type: String
}

struct DailyTrendItem: Equatable, Identifiable {
    var id: String { date }
    let date: String
    let amount: Double
}

struct TopSpendingItem: Equatable, Identifiable {
    var id: String { description + String(amount) }
    let description: String
    let amount: Double
    let category: String?
    let date: Date?
}
