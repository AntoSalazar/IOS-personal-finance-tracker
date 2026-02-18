import SwiftUI

struct AddCryptoView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: CryptoViewModel

    @State private var symbol = ""
    @State private var name = ""
    @State private var amount = ""
    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var purchaseFee = ""
    @State private var notes = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        HStack(spacing: AppSpacing.md) {
                            AppTextField(
                                title: "Symbol",
                                placeholder: "BTC",
                                text: $symbol
                            )
                            AppTextField(
                                title: "Name",
                                placeholder: "Bitcoin",
                                text: $name
                            )
                        }

                        AppTextField(
                            title: "Amount",
                            placeholder: "0.00",
                            text: $amount,
                            keyboardType: .decimalPad
                        )

                        AppTextField(
                            title: "Purchase Price (per unit)",
                            placeholder: "0.00",
                            text: $purchasePrice,
                            keyboardType: .decimalPad
                        )

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Purchase Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        AppTextField(
                            title: "Fee (Optional)",
                            placeholder: "0.00",
                            text: $purchaseFee,
                            keyboardType: .decimalPad
                        )

                        AppTextField(
                            title: "Notes (Optional)",
                            placeholder: "Additional notes",
                            text: $notes
                        )

                        AppButton(
                            title: "Add Holding",
                            icon: "plus.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: !isValid,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let success = await viewModel.createHolding(
                                    symbol: symbol.uppercased(),
                                    name: name,
                                    amount: Double(amount) ?? 0,
                                    purchasePrice: Double(purchasePrice) ?? 0,
                                    purchaseDate: purchaseDate,
                                    purchaseFee: Double(purchaseFee),
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
            .navigationTitle("Add Crypto")
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
        !symbol.isEmpty && !name.isEmpty && !amount.isEmpty && !purchasePrice.isEmpty &&
        (Double(amount) ?? 0) > 0 && (Double(purchasePrice) ?? 0) > 0
    }
}
