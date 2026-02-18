import Charts
import SwiftUI

struct StatsView: View {
    let statisticsViewModel: StatisticsViewModel
    let cryptoViewModel: CryptoViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if statisticsViewModel.isLoading && statisticsViewModel.statistics == nil {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            periodSelector

                            if let stats = statisticsViewModel.statistics {
                                summarySection(stats)
                                incomeExpenseBars(stats)

                                if stats.monthlyTrends.count > 1 {
                                    monthlyTrendsChart(stats)
                                }

                                if !stats.categoryBreakdown.isEmpty {
                                    categorySection(
                                        title: "Spending by Category",
                                        items: stats.categoryBreakdown,
                                        total: stats.expenses,
                                        color: Color.appChart1
                                    )
                                }

                                if !stats.incomeCategoryBreakdown.isEmpty {
                                    categorySection(
                                        title: "Income by Category",
                                        items: stats.incomeCategoryBreakdown,
                                        total: stats.income,
                                        color: Color.appChart2
                                    )
                                }

                                if !stats.accountBalances.isEmpty {
                                    accountBalancesSection(stats)
                                }

                                if !stats.topSpending.isEmpty {
                                    topSpendingSection(stats)
                                }
                            }

                            cryptoLink
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                    .refreshable {
                        await statisticsViewModel.loadStatistics()
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await statisticsViewModel.loadStatistics()
            }
        }
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        HStack(spacing: 4) {
            ForEach(StatsPeriod.allCases) { period in
                Button {
                    withAnimation(.appFast) {
                        statisticsViewModel.changePeriod(period.rawValue)
                    }
                } label: {
                    Text(period.title)
                        .font(.subheadline.weight(
                            statisticsViewModel.selectedPeriod == period.rawValue ? .semibold : .regular
                        ))
                        .foregroundStyle(
                            statisticsViewModel.selectedPeriod == period.rawValue
                                ? Color.appPrimaryForeground
                                : Color.appMutedForeground
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            statisticsViewModel.selectedPeriod == period.rawValue
                                ? Color.appPrimary
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                }
            }
        }
        .padding(4)
        .background(Color.appSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Summary

    private func summarySection(_ stats: FinancialStatistics) -> some View {
        AppCard {
            VStack(spacing: AppSpacing.md) {
                // Net income prominent
                VStack(spacing: AppSpacing.xs) {
                    Text("Net Income")
                        .font(.subheadline)
                        .foregroundStyle(Color.appMutedForeground)

                    Text(formatCurrency(stats.balance))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(stats.balance >= 0 ? Color.appChart2 : Color.appChart1)
                }

                Divider()

                // Key metrics row
                HStack(spacing: 0) {
                    metricItem(
                        label: "Savings",
                        value: String(format: "%.0f%%", stats.summary.savingsRate),
                        color: stats.summary.savingsRate >= 0 ? Color.appChart3 : Color.appChart1
                    )

                    dividerVertical

                    metricItem(
                        label: "Net Worth",
                        value: formatCompact(stats.netWorth),
                        color: Color.appChart4
                    )

                    dividerVertical

                    metricItem(
                        label: "Transactions",
                        value: "\(stats.summary.transactionCount)",
                        color: Color.appMutedForeground
                    )
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appMutedForeground)
        }
        .frame(maxWidth: .infinity)
    }

    private var dividerVertical: some View {
        Rectangle()
            .fill(Color.appBorder)
            .frame(width: 1, height: 32)
    }

    // MARK: - Income / Expense Bars

    private func incomeExpenseBars(_ stats: FinancialStatistics) -> some View {
        let maxVal = max(stats.income, stats.expenses, 1)

        return AppCard {
            VStack(spacing: AppSpacing.md) {
                // Income bar
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(Color.appChart2)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Income")
                                .font(.subheadline)
                                .foregroundStyle(Color.appCardForeground)
                            Spacer()
                            Text(formatCurrency(stats.income))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appChart2)
                        }

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appChart2)
                                .frame(
                                    width: geo.size.width * (stats.income / maxVal),
                                    height: 8
                                )
                        }
                        .frame(height: 8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appChart2.opacity(0.12))
                        )
                    }
                }

                // Expense bar
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(Color.appChart1)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Expenses")
                                .font(.subheadline)
                                .foregroundStyle(Color.appCardForeground)
                            Spacer()
                            Text(formatCurrency(stats.expenses))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appChart1)
                        }

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appChart1)
                                .frame(
                                    width: geo.size.width * (stats.expenses / maxVal),
                                    height: 8
                                )
                        }
                        .frame(height: 8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appChart1.opacity(0.12))
                        )
                    }
                }

                // Averages
                HStack {
                    HStack(spacing: AppSpacing.xs) {
                        Text("Avg income:")
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                        Text(formatCurrency(stats.summary.avgIncomeAmount))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appChart2)
                    }
                    Spacer()
                    HStack(spacing: AppSpacing.xs) {
                        Text("Avg expense:")
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                        Text(formatCurrency(stats.summary.avgExpenseAmount))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appChart1)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Monthly Trends Chart

    private func monthlyTrendsChart(_ stats: FinancialStatistics) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Monthly Trends")
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                Chart {
                    ForEach(stats.monthlyTrends) { trend in
                        BarMark(
                            x: .value("Month", shortMonth(trend.month)),
                            y: .value("Amount", trend.income)
                        )
                        .foregroundStyle(Color.appChart2)
                        .position(by: .value("Type", "Income"))

                        BarMark(
                            x: .value("Month", shortMonth(trend.month)),
                            y: .value("Amount", trend.expenses)
                        )
                        .foregroundStyle(Color.appChart1)
                        .position(by: .value("Type", "Expenses"))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(formatCompact(v))
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.appBorder)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 200)

                // Legend
                HStack(spacing: AppSpacing.lg) {
                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(Color.appChart2)
                            .frame(width: 8, height: 8)
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                    }

                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(Color.appChart1)
                            .frame(width: 8, height: 8)
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Category Breakdown

    private func categorySection(
        title: String,
        items: [CategoryBreakdownItem],
        total: Double,
        color: Color
    ) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                ForEach(Array(items.prefix(6).enumerated()), id: \.element.id) { index, item in
                    let pct = total > 0 ? item.amount / total : 0

                    VStack(spacing: 6) {
                        HStack {
                            HStack(spacing: AppSpacing.sm) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appCardForeground)
                                    .lineLimit(1)
                            }

                            Spacer()

                            HStack(spacing: AppSpacing.sm) {
                                Text(String(format: "%.0f%%", pct * 100))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.appMutedForeground)

                                Text(formatCurrency(item.amount))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(color)
                            }
                        }

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(chartColor(for: index))
                                .frame(width: geo.size.width * pct, height: 6)
                        }
                        .frame(height: 6)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.appSecondary)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Account Balances

    private func accountBalancesSection(_ stats: FinancialStatistics) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Account Balances")
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                ForEach(stats.accountBalances) { account in
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: accountIcon(for: account.type))
                            .font(.callout)
                            .foregroundStyle(Color.appChart4)
                            .frame(width: 32, height: 32)
                            .background(Color.appChart4.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .font(.subheadline)
                                .foregroundStyle(Color.appCardForeground)
                                .lineLimit(1)

                            Text(account.type.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.appMutedForeground)
                        }

                        Spacer()

                        Text(formatCurrency(account.balance))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                account.balance >= 0 ? Color.appCardForeground : Color.appChart1
                            )
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Top Spending

    private func topSpendingSection(_ stats: FinancialStatistics) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Top Spending")
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                ForEach(Array(stats.topSpending.prefix(5).enumerated()), id: \.element.id) {
                    index,
                    item in
                    HStack(spacing: AppSpacing.sm) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appMutedForeground)
                            .frame(width: 20, height: 20)
                            .background(Color.appSecondary)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundStyle(Color.appCardForeground)
                                .lineLimit(1)

                            if let category = item.category {
                                Text(category)
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                            }
                        }

                        Spacer()

                        Text(formatCurrency(item.amount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appChart1)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Crypto Link

    private var cryptoLink: some View {
        NavigationLink {
            CryptoView(viewModel: cryptoViewModel, accounts: [])
        } label: {
            AppCard {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appChart4)
                        .frame(width: 40, height: 40)
                        .background(Color.appChart4.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Crypto Portfolio")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appCardForeground)

                        if !cryptoViewModel.holdings.isEmpty {
                            Text(formatCurrency(cryptoViewModel.totalValue))
                                .font(.caption)
                                .foregroundStyle(Color.appChart4)
                        } else {
                            Text("View your holdings")
                                .font(.caption)
                                .foregroundStyle(Color.appMutedForeground)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appMutedForeground)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formatCompact(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        if absValue >= 1_000_000 {
            return "\(sign)$\(String(format: "%.1fM", absValue / 1_000_000))"
        } else if absValue >= 1_000 {
            return "\(sign)$\(String(format: "%.0fK", absValue / 1_000))"
        } else {
            return "\(sign)$\(String(format: "%.0f", absValue))"
        }
    }

    private func shortMonth(_ month: String) -> String {
        // month comes as "2026-01" format, extract short name
        let parts = month.split(separator: "-")
        guard parts.count == 2, let m = Int(parts[1]) else { return month }
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return m >= 1 && m <= 12 ? months[m - 1] : month
    }

    private func chartColor(for index: Int) -> Color {
        let colors: [Color] = [.appChart1, .appChart2, .appChart3, .appChart4, .appChart5, .appPrimary]
        return colors[index % colors.count]
    }

    private func accountIcon(for type: String) -> String {
        let lower = type.lowercased()
        if lower.contains("checking") { return "banknote" }
        if lower.contains("savings") { return "building.columns" }
        if lower.contains("credit") { return "creditcard" }
        if lower.contains("investment") { return "chart.line.uptrend.xyaxis" }
        if lower.contains("cash") { return "dollarsign.circle" }
        return "banknote"
    }
}

// MARK: - Stats Period

private enum StatsPeriod: String, CaseIterable, Identifiable {
    case month
    case quarter
    case year
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        case .all: return "All"
        }
    }
}
