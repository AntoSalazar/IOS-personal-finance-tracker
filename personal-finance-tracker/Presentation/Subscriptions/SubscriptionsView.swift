import SwiftUI

struct SubscriptionsView: View {
    @Bindable var viewModel: SubscriptionsViewModel
    let accounts: [Account]
    let categories: [Category]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.subscriptions.isEmpty {
                    LoadingView(message: "Loading subscriptions...")
                } else if let error = viewModel.errorMessage, viewModel.subscriptions.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadSubscriptions() }
                    }
                } else if viewModel.subscriptions.isEmpty {
                    emptyState
                } else {
                    subscriptionsList
                }
            }
            .navigationTitle("Subscriptions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddSubscription) {
                AddSubscriptionView(
                    viewModel: viewModel,
                    accounts: accounts,
                    categories: categories
                )
            }
            .task {
                if viewModel.subscriptions.isEmpty {
                    await viewModel.loadSubscriptions()
                }
            }
            .refreshable {
                await viewModel.loadSubscriptions()
            }
        }
    }

    private var subscriptionsList: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Summary Header
                if let summary = viewModel.summary {
                    AppCard {
                        HStack(spacing: AppSpacing.lg) {
                            VStack(spacing: AppSpacing.xs) {
                                Text("Monthly")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(summary.totalMonthly))
                                    .font(.headline)
                                    .foregroundStyle(Color.appChart1)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(spacing: AppSpacing.xs) {
                                Text("Yearly")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(summary.totalYearly))
                                    .font(.headline)
                                    .foregroundStyle(Color.appChart1)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(spacing: AppSpacing.xs) {
                                Text("Active")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text("\(summary.count)")
                                    .font(.headline)
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }

                // Subscriptions List
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.subscriptions) { subscription in
                        AppCard {
                            SubscriptionRow(subscription: subscription)
                        }
                        .contextMenu {
                            if subscription.status == .active {
                                Button {
                                    Task { await viewModel.processSubscription(id: subscription.id) }
                                } label: {
                                    Label("Process Payment", systemImage: "creditcard")
                                }
                            }
                            Button(role: .destructive) {
                                Task { await viewModel.deleteSubscription(id: subscription.id) }
                            } label: {
                                Label("Delete", systemImage: "trash")
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
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appMutedForeground)

            Text("No Subscriptions")
                .font(.title2.bold())
                .foregroundStyle(Color.appForeground)

            Text("Track your recurring payments and subscriptions")
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            AppButton(
                title: "Add Subscription",
                icon: "plus.circle.fill",
                variant: .primary
            ) {
                viewModel.showAddSubscription = true
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
