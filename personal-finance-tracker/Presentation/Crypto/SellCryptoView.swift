import SwiftUI

struct SellCryptoView: View {
    @Environment(\.dismiss) private var dismiss
    let holding: CryptoHolding
    let viewModel: CryptoViewModel
    let accounts: [Account]

    @State private var salePrice = ""
    @State private var saleDate = Date()
    @State private var saleFee = ""
    @State private var selectedAccountId: String?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Holding Info
                        AppCard {
                            VStack(spacing: AppSpacing.sm) {
                                Text(holding.symbol.uppercased())
                                    .font(.title.bold())
                                    .foregroundStyle(Color.appForeground)
                                Text(holding.name)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)
                                Text("\(formatNumber(holding.amount)) units")
                                    .font(.caption)
                                    .foregroundStyle(Color.appMutedForeground)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        AppTextField(
                            title: "Sale Price (per unit)",
                            placeholder: "0.00",
                            text: $salePrice,
                            keyboardType: .decimalPad
                        )

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Sale Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appForeground)

                            DatePicker("", selection: $saleDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        AppTextField(
                            title: "Fee (Optional)",
                            placeholder: "0.00",
                            text: $saleFee,
                            keyboardType: .decimalPad
                        )

                        // Deposit Account
                        if !accounts.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Deposit To (Optional)")
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

                        AppButton(
                            title: "Sell",
                            icon: "arrow.up.circle.fill",
                            variant: .destructive,
                            isLoading: isSaving,
                            isDisabled: salePrice.isEmpty || (Double(salePrice) ?? 0) <= 0,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let success = await viewModel.sellHolding(
                                    id: holding.id,
                                    salePrice: Double(salePrice) ?? 0,
                                    saleDate: saleDate,
                                    saleFee: Double(saleFee),
                                    saleAccountId: selectedAccountId
                                )
                                isSaving = false
                                if success { dismiss() }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("Sell \(holding.symbol.uppercased())")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
