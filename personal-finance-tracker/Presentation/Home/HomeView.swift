import SwiftUI

struct HomeView: View {
    @Bindable var authViewModel: AuthViewModel
    @Bindable var transactionsViewModel: TransactionsViewModel
    let statisticsViewModel: StatisticsViewModel
    let accounts: [Account]
    let categories: [Category]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Greeting
                        if let user = authViewModel.state.currentUser {
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Hello, \(firstName(user.name))")
                                        .font(.title2.bold())
                                        .foregroundStyle(Color.appForeground)

                                    Text(formattedDate)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appMutedForeground)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }

                        // Balance Overview
                        balanceCard

                        // Quick Actions
                        HStack(spacing: AppSpacing.md) {
                            QuickActionButton(
                                title: "Add",
                                icon: "plus.circle.fill",
                                color: Color.appPrimary
                            ) {
                                transactionsViewModel.showAddTransaction = true
                            }

                            QuickActionButton(
                                title: "Accounts",
                                icon: "creditcard.fill",
                                color: Color.appChart4
                            ) {
                                // Navigate handled by tab
                            }

                            QuickActionButton(
                                title: "Stats",
                                icon: "chart.bar.fill",
                                color: Color.appChart2
                            ) {
                                // Navigate handled by tab
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Recent Transactions
                        recentTransactionsSection
                    }
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $transactionsViewModel.showAddTransaction) {
                AddTransactionView(
                    viewModel: transactionsViewModel,
                    accounts: accounts,
                    categories: categories
                )
            }
            .task {
                async let loadStats: () = statisticsViewModel.loadHomeStatistics()
                async let loadTx: () = transactionsViewModel.loadTransactions()
                _ = await (loadStats, loadTx)
            }
            .refreshable {
                async let loadStats: () = statisticsViewModel.loadHomeStatistics()
                async let loadTx: () = transactionsViewModel.loadTransactions()
                _ = await (loadStats, loadTx)
            }
        }
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.md) {
                if statisticsViewModel.isLoadingHome && statisticsViewModel.homeStatistics == nil {
                    ProgressView()
                        .padding(.vertical, AppSpacing.lg)
                } else {
                    // Overall header
                    HStack {
                        Text("All Time")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appMutedForeground)
                        Spacer()
                    }

                    // Net Balance
                    VStack(spacing: AppSpacing.xs) {
                        Text(formatCurrency(statisticsViewModel.homeStatistics?.balance ?? 0))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(balanceColor)
                    }

                    Divider()

                    // Income & Expenses row
                    HStack {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.body)
                                .foregroundStyle(Color.appChart2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Income")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(statisticsViewModel.homeStatistics?.income ?? 0))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appChart2)
                            }
                        }

                        Spacer()

                        HStack(spacing: AppSpacing.sm) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Expenses")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(statisticsViewModel.homeStatistics?.expenses ?? 0))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appChart1)
                            }

                            Image(systemName: "arrow.up.circle.fill")
                                .font(.body)
                                .foregroundStyle(Color.appChart1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private var balanceColor: Color {
        let balance = statisticsViewModel.homeStatistics?.balance ?? 0
        if balance > 0 { return Color.appChart2 }
        if balance < 0 { return Color.appChart1 }
        return Color.appForeground
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundStyle(Color.appForeground)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)

            let recentTransactions = Array(transactionsViewModel.state.transactions.prefix(5))

            if transactionsViewModel.state.isLoading && recentTransactions.isEmpty {
                AppCard {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.lg)
            } else if recentTransactions.isEmpty {
                AppCard {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "tray")
                            .font(.title)
                            .foregroundStyle(Color.appMutedForeground)

                        Text("No transactions yet")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)

                        AppButton(
                            title: "Add Your First",
                            icon: "plus.circle.fill",
                            variant: .primary
                        ) {
                            transactionsViewModel.showAddTransaction = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                }
                .padding(.horizontal, AppSpacing.lg)
            } else {
                AppCard {
                    VStack(spacing: 0) {
                        ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.vertical, AppSpacing.sm)

                            if index < recentTransactions.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }

    // MARK: - Helpers

    private func firstName(_ fullName: String) -> String {
        fullName.components(separatedBy: " ").first ?? fullName
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Quick Action Button

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appForeground)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
