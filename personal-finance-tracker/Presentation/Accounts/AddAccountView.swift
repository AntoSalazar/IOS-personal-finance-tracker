import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: AccountsViewModel

    @State private var name = ""
    @State private var selectedType: AccountType = .checking
    @State private var balance = ""
    @State private var currency = "MXN"
    @State private var description = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        AppTextField(
                            title: "Account Name",
                            placeholder: "e.g., Main Checking",
                            text: $name
                        )

                        // Type Picker
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Account Type")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: AppSpacing.sm) {
                                ForEach(AccountType.allCases) { type in
                                    Button {
                                        selectedType = type
                                    } label: {
                                        VStack(spacing: AppSpacing.xs) {
                                            Image(systemName: type.icon)
                                                .font(.title3)
                                            Text(type.title)
                                                .font(.caption)
                                        }
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
                            title: "Initial Balance",
                            placeholder: "0.00",
                            text: $balance,
                            keyboardType: .decimalPad
                        )

                        AppTextField(
                            title: "Description (Optional)",
                            placeholder: "Add a note about this account",
                            text: $description
                        )

                        AppButton(
                            title: "Create Account",
                            icon: "plus.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: name.isEmpty,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let balanceValue = Double(balance) ?? 0
                                let success = await viewModel.createAccount(
                                    name: name,
                                    type: selectedType,
                                    balance: balanceValue,
                                    currency: currency,
                                    description: description.isEmpty ? nil : description
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
            .navigationTitle("New Account")
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
}
