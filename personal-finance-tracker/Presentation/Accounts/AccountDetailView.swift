import SwiftUI

struct AccountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let account: Account
    let viewModel: AccountsViewModel

    @State private var name: String
    @State private var selectedType: AccountType
    @State private var balance: String
    @State private var description: String
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var showDeleteAlert = false

    init(account: Account, viewModel: AccountsViewModel) {
        self.account = account
        self.viewModel = viewModel
        _name = State(initialValue: account.name)
        _selectedType = State(initialValue: account.type)
        _balance = State(initialValue: String(format: "%.2f", account.balance))
        _description = State(initialValue: account.description ?? "")
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Account Header
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: account.type.icon)
                            .font(.system(size: 48))
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 80, height: 80)
                            .background(Color.appSecondary)
                            .clipShape(Circle())

                        Text(formatCurrency(account.balance, currency: account.currency))
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.appForeground)

                        Text(account.type.title)
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .background(Color.appSecondary)
                            .clipShape(Capsule())
                    }
                    .padding(.top, AppSpacing.lg)

                    if isEditing {
                        // Edit Form
                        VStack(spacing: AppSpacing.lg) {
                            AppTextField(
                                title: "Account Name",
                                placeholder: "Account name",
                                text: $name
                            )

                            AppTextField(
                                title: "Balance",
                                placeholder: "0.00",
                                text: $balance,
                                keyboardType: .decimalPad
                            )

                            AppTextField(
                                title: "Description",
                                placeholder: "Optional description",
                                text: $description
                            )

                            HStack(spacing: AppSpacing.md) {
                                AppButton(
                                    title: "Cancel",
                                    variant: .outline
                                ) {
                                    isEditing = false
                                    resetFields()
                                }

                                AppButton(
                                    title: "Save",
                                    variant: .primary,
                                    isLoading: isSaving,
                                    fullWidth: true
                                ) {
                                    Task {
                                        isSaving = true
                                        let success = await viewModel.updateAccount(
                                            id: account.id,
                                            name: name,
                                            type: selectedType,
                                            balance: Double(balance),
                                            description: description.isEmpty ? nil : description
                                        )
                                        isSaving = false
                                        if success {
                                            isEditing = false
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    } else {
                        // Info Card
                        AppCard {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                InfoRow(label: "Name", value: account.name)
                                InfoRow(label: "Type", value: account.type.title)
                                InfoRow(label: "Currency", value: account.currency)
                                InfoRow(label: "Status", value: account.isActive ? "Active" : "Inactive")
                                if let desc = account.description, !desc.isEmpty {
                                    InfoRow(label: "Description", value: desc)
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    // Delete Button
                    if !isEditing {
                        AppButton(
                            title: "Delete Account",
                            icon: "trash.fill",
                            variant: .destructive,
                            fullWidth: true
                        ) {
                            showDeleteAlert = true
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteAccount(id: account.id)
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(account.name)\"? This action cannot be undone.")
        }
    }

    private func resetFields() {
        name = account.name
        selectedType = account.type
        balance = String(format: "%.2f", account.balance)
        description = account.description ?? ""
    }

    private func formatCurrency(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appCardForeground)
        }
    }
}
