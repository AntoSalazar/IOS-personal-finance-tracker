import Foundation

struct StatisticsDTO: Codable {
    let period: String?
    let dateRange: DateRangeDTO?
    let summary: StatsSummaryDTO?
    let categoryBreakdown: [CategoryBreakdownDTO]?
    let incomeCategoryBreakdown: [CategoryBreakdownDTO]?
    let monthlyTrends: [MonthlyTrendDTO]?
    let accountBalances: [AccountBalanceDTO]?
    let dailyTrend: [DailyTrendDTO]?
    let topSpending: [TopSpendingDTO]?

    func toDomain() -> FinancialStatistics {
        FinancialStatistics(
            period: period ?? "month",
            dateRange: dateRange?.toDomain(),
            summary: summary?.toDomain() ?? StatsSummary(
                totalIncome: 0, totalExpenses: 0, netIncome: 0,
                savingsRate: 0, netWorth: 0, transactionCount: 0,
                avgExpenseAmount: 0, avgIncomeAmount: 0
            ),
            categoryBreakdown: categoryBreakdown?.map { $0.toDomain() } ?? [],
            incomeCategoryBreakdown: incomeCategoryBreakdown?.map { $0.toDomain() } ?? [],
            monthlyTrends: monthlyTrends?.map { $0.toDomain() } ?? [],
            accountBalances: accountBalances?.map { $0.toDomain() } ?? [],
            dailyTrend: dailyTrend?.map { $0.toDomain() } ?? [],
            topSpending: topSpending?.map { $0.toDomain() } ?? []
        )
    }
}

struct DateRangeDTO: Codable {
    let start: Date?
    let end: Date?

    func toDomain() -> DateRange {
        DateRange(start: start ?? Date(), end: end ?? Date())
    }
}

struct StatsSummaryDTO: Codable {
    let totalIncome: Double?
    let totalExpenses: Double?
    let netIncome: Double?
    let savingsRate: Double?
    let netWorth: Double?
    let transactionCount: Int?
    let avgExpenseAmount: Double?
    let avgIncomeAmount: Double?

    func toDomain() -> StatsSummary {
        StatsSummary(
            totalIncome: totalIncome ?? 0,
            totalExpenses: totalExpenses ?? 0,
            netIncome: netIncome ?? 0,
            savingsRate: savingsRate ?? 0,
            netWorth: netWorth ?? 0,
            transactionCount: transactionCount ?? 0,
            avgExpenseAmount: avgExpenseAmount ?? 0,
            avgIncomeAmount: avgIncomeAmount ?? 0
        )
    }
}

struct CategoryBreakdownDTO: Codable {
    let name: String?
    let amount: Double?
    let count: Int?
    let color: String?

    func toDomain() -> CategoryBreakdownItem {
        CategoryBreakdownItem(
            name: name ?? "Unknown",
            amount: amount ?? 0,
            count: count ?? 0,
            color: color
        )
    }
}

struct MonthlyTrendDTO: Codable {
    let month: String?
    let income: Double?
    let expenses: Double?
    let net: Double?

    func toDomain() -> MonthlyTrend {
        MonthlyTrend(
            month: month ?? "",
            income: income ?? 0,
            expenses: expenses ?? 0,
            net: net ?? 0
        )
    }
}

struct AccountBalanceDTO: Codable {
    let name: String?
    let balance: Double?
    let type: String?

    func toDomain() -> AccountBalance {
        AccountBalance(
            name: name ?? "",
            balance: balance ?? 0,
            type: type ?? ""
        )
    }
}

struct DailyTrendDTO: Codable {
    let date: String?
    let amount: Double?

    func toDomain() -> DailyTrendItem {
        DailyTrendItem(
            date: date ?? "",
            amount: amount ?? 0
        )
    }
}

struct TopSpendingDTO: Codable {
    let description: String?
    let amount: Double?
    let category: String?
    let date: Date?

    func toDomain() -> TopSpendingItem {
        TopSpendingItem(
            description: description ?? "",
            amount: amount ?? 0,
            category: category,
            date: date
        )
    }
}
