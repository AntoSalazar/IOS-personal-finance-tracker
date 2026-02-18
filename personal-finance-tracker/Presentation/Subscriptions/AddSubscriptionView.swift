import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: SubscriptionsViewModel
    let accounts: [Account]
    let categories: [Category]

    @State private var name = ""
    @State private var amount = ""
    @State private var selectedFrequency: SubscriptionFrequency = .monthly
    @State private var nextBillingDate = Date()
    @State private var selectedAccountId: String?
    @State private var selectedCategoryId: String?
    @State private var notes = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        AppTextField(
                            title: "Name",
                            placeholder: "e.g., Netflix, Spotify",
                            text: $name
                        )

                        AppTextField(
                            title: "Amount",
                            placeholder: "0.00",
                            text: $amount,
                            keyboardType: .decimalPad
                        )

                        // Frequency Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Frequency")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            HStack(spacing: AppSpacing.sm) {
                                ForEach(SubscriptionFrequency.allCases) { freq in
                                    Button {
                                        selectedFrequency = freq
                                    } label: {
                                        Text(freq.title)
                                            .font(.caption.weight(.medium))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, AppSpacing.sm)
                                            .foregroundStyle(selectedFrequency == freq ? Color.appPrimaryForeground : Color.appForeground)
                                            .background(selectedFrequency == freq ? Color.appPrimary : Color.appSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                    }
                                }
                            }
                        }

                        // Next Billing Date
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Next Billing Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            DatePicker("", selection: $nextBillingDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        // Account Picker
                        if !accounts.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Account (Optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.appForeground)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppSpacing.sm) {
                                        ForEach(accounts) { account in
                                            Button {
                                                selectedAccountId = selectedAccountId == account.id ? nil : account.id
                                            } label: {
                                                Text(account.name)
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

                        AppTextField(
                            title: "Notes (Optional)",
                            placeholder: "Add any notes",
                            text: $notes
                        )

                        AppButton(
                            title: "Add Subscription",
                            icon: "plus.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: !isValid,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let amountValue = Double(amount) ?? 0
                                let success = await viewModel.createSubscription(
                                    name: name,
                                    amount: amountValue,
                                    frequency: selectedFrequency,
                                    nextBillingDate: nextBillingDate,
                                    accountId: selectedAccountId,
                                    categoryId: selectedCategoryId,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                isSaving = false
                                if success { dismiss() }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
}
