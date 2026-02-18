import SwiftUI

struct DebtsView: View {
    @Bindable var viewModel: DebtsViewModel
    let accounts: [Account]
    let categories: [Category]

    @State private var debtToPay: Debt?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.debts.isEmpty {
                    LoadingView(message: "Loading debts...")
                } else if let error = viewModel.errorMessage, viewModel.debts.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.loadDebts() }
                    }
                } else if viewModel.debts.isEmpty {
                    emptyState
                } else {
                    debtsList
                }
            }
            .navigationTitle("Debts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppSpacing.sm) {
                        Button {
                            viewModel.showPaidFilter.toggle()
                            Task { await viewModel.loadDebts() }
                        } label: {
                            Image(systemName: viewModel.showPaidFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.body.weight(.semibold))
                        }

                        Button {
                            viewModel.showAddDebt = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddDebt) {
                AddDebtView(viewModel: viewModel)
            }
            .sheet(item: $debtToPay) { debt in
                PayDebtView(
                    debt: debt,
                    viewModel: viewModel,
                    accounts: accounts,
                    categories: categories
                )
            }
            .task {
                if viewModel.debts.isEmpty {
                    await viewModel.loadDebts()
                }
            }
            .refreshable {
                await viewModel.loadDebts()
            }
        }
    }

    private var debtsList: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Summary Header
                if let summary = viewModel.summary {
                    AppCard {
                        HStack(spacing: AppSpacing.lg) {
                            VStack(spacing: AppSpacing.xs) {
                                Text("Owed")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(summary.totalOwed))
                                    .font(.headline)
                                    .foregroundStyle(Color.appChart1)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(spacing: AppSpacing.xs) {
                                Text("Paid")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text(formatCurrency(summary.totalPaid))
                                    .font(.headline)
                                    .foregroundStyle(Color.appChart2)
                            }
                            .frame(maxWidth: .infinity)

                            Divider()

                            VStack(spacing: AppSpacing.xs) {
                                Text("Total")
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

                // Debts List
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.debts) { debt in
                        AppCard {
                            DebtRow(debt: debt)
                        }
                        .contextMenu {
                            if !debt.isPaid {
                                Button {
                                    debtToPay = debt
                                } label: {
                                    Label("Mark as Paid", systemImage: "checkmark.circle")
                                }
                            }
                            Button(role: .destructive) {
                                Task { await viewModel.deleteDebt(id: debt.id) }
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
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appMutedForeground)

            Text("No Debts")
                .font(.title2.bold())
                .foregroundStyle(Color.appForeground)

            Text("Track money you owe or are owed")
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            AppButton(
                title: "Add Debt",
                icon: "plus.circle.fill",
                variant: .primary
            ) {
                viewModel.showAddDebt = true
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

// MARK: - Pay Debt View

private struct PayDebtView: View {
    @Environment(\.dismiss) private var dismiss
    let debt: Debt
    let viewModel: DebtsViewModel
    let accounts: [Account]
    let categories: [Category]

    @State private var selectedAccountId: String = ""
    @State private var selectedCategoryId: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Debt Info
                        AppCard {
                            VStack(spacing: AppSpacing.sm) {
                                Text(debt.personName)
                                    .font(.headline)
                                    .foregroundStyle(Color.appCardForeground)

                                Text(formatCurrency(debt.amount))
                                    .font(.title.bold())
                                    .foregroundStyle(Color.appChart1)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Account Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Pay from Account")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.appForeground)

                            if accounts.isEmpty {
                                Text("No accounts available")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)
                                    .padding(AppSpacing.md)
                            } else {
                                ForEach(accounts) { account in
                                    Button {
                                        selectedAccountId = account.id
                                    } label: {
                                        HStack {
                                            Image(systemName: account.type.icon)
                                                .foregroundStyle(Color.appPrimary)
                                            Text(account.name)
                                                .foregroundStyle(Color.appCardForeground)
                                            Spacer()
                                            if selectedAccountId == account.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(Color.appPrimary)
                                            }
                                        }
                                        .padding(AppSpacing.md)
                                        .background(selectedAccountId == account.id ? Color.appSecondary : Color.appCard)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                    }
                                }
                            }
                        }

                        // Category Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Category")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.appForeground)

                            if categories.isEmpty {
                                Text("No categories available")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)
                                    .padding(AppSpacing.md)
                            } else {
                                ForEach(categories) { category in
                                    Button {
                                        selectedCategoryId = category.id
                                    } label: {
                                        HStack {
                                            Text(category.name)
                                                .foregroundStyle(Color.appCardForeground)
                                            Spacer()
                                            if selectedCategoryId == category.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(Color.appPrimary)
                                            }
                                        }
                                        .padding(AppSpacing.md)
                                        .background(selectedCategoryId == category.id ? Color.appSecondary : Color.appCard)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                    }
                                }
                            }
                        }

                        AppButton(
                            title: "Confirm Payment",
                            icon: "checkmark.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: selectedAccountId.isEmpty || selectedCategoryId.isEmpty,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let success = await viewModel.markAsPaid(
                                    id: debt.id,
                                    accountId: selectedAccountId,
                                    categoryId: selectedCategoryId
                                )
                                isSaving = false
                                if success { dismiss() }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("Pay Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
