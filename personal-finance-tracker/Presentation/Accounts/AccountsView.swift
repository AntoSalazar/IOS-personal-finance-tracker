import SwiftUI

struct AccountsView: View {
    @Bindable var viewModel: AccountsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        LoadingView(message: "Loading accounts...")

                    case .success(let accounts, let totalBalance):
                        if accounts.isEmpty {
                            emptyState
                        } else {
                            accountsList(accounts: accounts, totalBalance: totalBalance)
                        }

                    case .error(let message):
                        ErrorView(message: message) {
                            Task { await viewModel.loadAccounts() }
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddAccount) {
                AddAccountView(viewModel: viewModel)
            }
            .task {
                if case .idle = viewModel.state {
                    await viewModel.loadAccounts()
                }
            }
            .refreshable {
                await viewModel.loadAccounts()
            }
        }
    }

    private func accountsList(accounts: [Account], totalBalance: Double) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Total Balance Header
                AppCard {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Total Balance")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)

                        Text(formatCurrency(totalBalance))
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.appForeground)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpacing.lg)

                // Accounts List
                VStack(spacing: AppSpacing.sm) {
                    ForEach(accounts) { account in
                        NavigationLink(destination: AccountDetailView(account: account, viewModel: viewModel)) {
                            AppCard {
                                AccountRow(account: account)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appMutedForeground)

            Text("No Accounts Yet")
                .font(.title2.bold())
                .foregroundStyle(Color.appForeground)

            Text("Add your first account to start tracking your finances")
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            AppButton(
                title: "Add Account",
                icon: "plus.circle.fill",
                variant: .primary
            ) {
                viewModel.showAddAccount = true
            }
            .padding(.top, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
