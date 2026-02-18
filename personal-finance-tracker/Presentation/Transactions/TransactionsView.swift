import SwiftUI

struct TransactionsView: View {
    @Bindable var viewModel: TransactionsViewModel
    let accounts: [Account]
    let categories: [Category]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingView(message: "Loading transactions...")

                    case .success(let transactions):
                        if transactions.isEmpty && viewModel.selectedTypeFilter == nil {
                            emptyState
                        } else {
                            transactionsList
                        }

                    case .error(let message):
                        ErrorView(message: message) {
                            Task { await viewModel.loadTransactions() }
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showAddTransaction = true
                        } label: {
                            Label("New Transaction", systemImage: "plus.circle")
                        }
                        Button {
                            viewModel.showTransfer = true
                        } label: {
                            Label("Transfer", systemImage: "arrow.left.arrow.right")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddTransaction) {
                AddTransactionView(
                    viewModel: viewModel,
                    accounts: accounts,
                    categories: categories
                )
            }
            .sheet(isPresented: $viewModel.showTransfer) {
                TransferView(
                    viewModel: viewModel,
                    accounts: accounts
                )
            }
            .task {
                if case .idle = viewModel.state {
                    await viewModel.loadTransactions()
                }
            }
            .refreshable {
                await viewModel.loadTransactions()
            }
        }
    }

    private var transactionsList: some View {
        VStack(spacing: 0) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterPill(title: "All", isSelected: viewModel.selectedTypeFilter == nil) {
                        viewModel.applyFilter(type: nil)
                    }
                    ForEach([TransactionType.income, .expense, .transfer]) { type in
                        FilterPill(title: type.title, isSelected: viewModel.selectedTypeFilter == type) {
                            viewModel.applyFilter(type: type)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
            }

            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        AppCard {
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "arrow.left.arrow.right.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.appMutedForeground)

            Text("No Transactions Yet")
                .font(.title2.bold())
                .foregroundStyle(Color.appForeground)

            Text("Start tracking your income and expenses by adding your first transaction")
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            AppButton(
                title: "Add Transaction",
                icon: "plus.circle.fill",
                variant: .primary
            ) {
                viewModel.showAddTransaction = true
            }
            .padding(.top, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.appPrimaryForeground : Color.appForeground)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? Color.appPrimary : Color.appSecondary)
                .clipShape(Capsule())
        }
    }
}
