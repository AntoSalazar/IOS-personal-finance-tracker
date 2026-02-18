import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: TransactionsViewModel
    let accounts: [Account]
    let categories: [Category]

    @State private var selectedType: TransactionType = .expense
    @State private var amount = ""
    @State private var description = ""
    @State private var reason = ""
    @State private var selectedAccountId: String?
    @State private var selectedCategoryId: String?
    @State private var date = Date()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Type Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Type")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            HStack(spacing: AppSpacing.sm) {
                                ForEach([TransactionType.expense, .income]) { type in
                                    Button {
                                        selectedType = type
                                    } label: {
                                        HStack(spacing: AppSpacing.xs) {
                                            Image(systemName: type.icon)
                                            Text(type.title)
                                        }
                                        .font(.subheadline.weight(.medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, AppSpacing.sm)
                                        .foregroundStyle(selectedType == type ? Color.appPrimaryForeground : Color.appForeground)
                                        .background(selectedType == type ? Color.appPrimary : Color.appSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                    }
                                }
                            }
                        }

                        AppTextField(
                            title: "Amount",
                            placeholder: "0.00",
                            text: $amount,
                            keyboardType: .decimalPad
                        )

                        AppTextField(
                            title: "Description",
                            placeholder: "What was this for?",
                            text: $description
                        )

                        AppTextField(
                            title: "Reason (Optional)",
                            placeholder: "Why did you make this transaction?",
                            text: $reason
                        )

                        // Account Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            if accounts.isEmpty {
                                Text("No accounts available. Create an account first.")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppSpacing.sm) {
                                        ForEach(accounts) { account in
                                            Button {
                                                selectedAccountId = account.id
                                            } label: {
                                                HStack(spacing: AppSpacing.xs) {
                                                    Image(systemName: account.type.icon)
                                                    Text(account.name)
                                                }
                                                .font(.caption.weight(.medium))
                                                .padding(.horizontal, AppSpacing.md)
                                                .padding(.vertical, AppSpacing.sm)
                                                .foregroundStyle(selectedAccountId == account.id ? Color.appPrimaryForeground : Color.appForeground)
                                                .background(selectedAccountId == account.id ? Color.appPrimary : Color.appSecondary)
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Category Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Category (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            if categories.isEmpty {
                                Text("No categories available")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppSpacing.sm) {
                                        ForEach(filteredCategories) { category in
                                            Button {
                                                selectedCategoryId = selectedCategoryId == category.id ? nil : category.id
                                            } label: {
                                                Text(category.name)
                                                    .font(.caption.weight(.medium))
                                                    .padding(.horizontal, AppSpacing.md)
                                                    .padding(.vertical, AppSpacing.sm)
                                                    .foregroundStyle(selectedCategoryId == category.id ? Color.appPrimaryForeground : Color.appForeground)
                                                    .background(selectedCategoryId == category.id ? Color.appPrimary : Color.appSecondary)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Date Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        AppButton(
                            title: "Add Transaction",
                            icon: "plus.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: !isValid,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let amountValue = Double(amount) ?? 0
                                let success = await viewModel.createTransaction(
                                    accountId: selectedAccountId!,
                                    amount: amountValue,
                                    type: selectedType,
                                    description: description,
                                    reason: reason.isEmpty ? nil : reason,
                                    categoryId: selectedCategoryId,
                                    date: date
                                )
                                isSaving = false
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private var filteredCategories: [Category] {
        let type: CategoryType = selectedType == .income ? .income : .expense
        return categories.filter { $0.type == type }
    }

    private var isValid: Bool {
        !amount.isEmpty && !description.isEmpty && selectedAccountId != nil && (Double(amount) ?? 0) > 0
    }
}
