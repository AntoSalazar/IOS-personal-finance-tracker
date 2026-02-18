import SwiftUI

struct CryptoView: View {
    @Bindable var viewModel: CryptoViewModel
    let accounts: [Account]

    @State private var holdingToSell: CryptoHolding?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.holdings.isEmpty {
                    LoadingView(message: "Loading portfolio...")
                } else if let error = viewModel.errorMessage, viewModel.holdings.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadPortfolio() }
                    }
                } else if viewModel.holdings.isEmpty {
                    emptyState
                } else {
                    portfolioList
                }
            }
            .navigationTitle("Crypto")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppSpacing.sm) {
                        Button {
                            Task { await viewModel.refreshPrices() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.body.weight(.semibold))
                        }

                        Button {
                            viewModel.showAddHolding = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddHolding) {
                AddCryptoView(viewModel: viewModel)
            }
            .sheet(item: $holdingToSell) { holding in
                SellCryptoView(
                    holding: holding,
                    viewModel: viewModel,
                    accounts: accounts
                )
            }
            .task {
                if viewModel.holdings.isEmpty {
                    await viewModel.loadPortfolio()
                }
            }
            .refreshable {
                await viewModel.loadPortfolio()
            }
        }
    }

    private var portfolioList: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Portfolio Summary
                AppCard {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Portfolio Value")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)

                        Text(formatCurrency(viewModel.totalValue))
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.appForeground)

                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: viewModel.totalProfitLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption)
                            Text(formatCurrency(abs(viewModel.totalProfitLoss)))
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(viewModel.totalProfitLoss >= 0 ? Color.appChart2 : Color.appChart1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpacing.lg)

                // Holdings List
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.holdings) { holding in
                        AppCard {
                            CryptoHoldingRow(holding: holding)
                        }
                        .contextMenu {
                            Button {
                                holdingToSell = holding
                            } label: {
                                Label("Sell", systemImage: "arrow.up.circle")
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appMutedForeground)

            Text("No Crypto Holdings")
                .font(.title2.bold())
                .foregroundStyle(Color.appForeground)

            Text("Track your cryptocurrency investments")
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            AppButton(
                title: "Add Holding",
                icon: "plus.circle.fill",
                variant: .primary
            ) {
                viewModel.showAddHolding = true
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
