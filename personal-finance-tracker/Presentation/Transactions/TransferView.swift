import SwiftUI

struct TransferView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: TransactionsViewModel
    let accounts: [Account]

    @State private var fromAccountId: String?
    @State private var toAccountId: String?
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // From Account
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("From Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.sm) {
                                    ForEach(accounts) { account in
                                        Button {
                                            fromAccountId = account.id
                                        } label: {
                                            HStack(spacing: AppSpacing.xs) {
                                                Image(systemName: account.type.icon)
                                                Text(account.name)
                                            }
                                            .font(.caption.weight(.medium))
                                            .padding(.horizontal, AppSpacing.md)
                                            .padding(.vertical, AppSpacing.sm)
                                            .foregroundStyle(fromAccountId == account.id ? Color.appPrimaryForeground : Color.appForeground)
                                            .background(fromAccountId == account.id ? Color.appPrimary : Color.appSecondary)
                                            .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }

                        Image(systemName: "arrow.down")
                            .font(.title2)
                            .foregroundStyle(Color.appMutedForeground)

                        // To Account
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("To Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.sm) {
                                    ForEach(availableToAccounts) { account in
                                        Button {
                                            toAccountId = account.id
                                        } label: {
                                            HStack(spacing: AppSpacing.xs) {
                                                Image(systemName: account.type.icon)
                                                Text(account.name)
                                            }
                                            .font(.caption.weight(.medium))
                                            .padding(.horizontal, AppSpacing.md)
                                            .padding(.vertical, AppSpacing.sm)
                                            .foregroundStyle(toAccountId == account.id ? Color.appPrimaryForeground : Color.appForeground)
                                            .background(toAccountId == account.id ? Color.appPrimary : Color.appSecondary)
                                            .clipShape(Capsule())
                                        }
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
                            placeholder: "Transfer description",
                            text: $description
                        )

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
                            title: "Transfer",
                            icon: "arrow.left.arrow.right",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: !isValid,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let amountValue = Double(amount) ?? 0
                                let success = await viewModel.createTransfer(
                                    fromAccountId: fromAccountId!,
                                    toAccountId: toAccountId!,
                                    amount: amountValue,
                                    description: description.isEmpty ? "Transfer" : description,
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
            .navigationTitle("Transfer")
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

    private var availableToAccounts: [Account] {
        accounts.filter { $0.id != fromAccountId }
    }

    private var isValid: Bool {
        fromAccountId != nil && toAccountId != nil && !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
}
