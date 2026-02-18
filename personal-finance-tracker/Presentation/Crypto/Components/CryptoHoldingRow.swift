import SwiftUI

struct CryptoHoldingRow: View {
    let holding: CryptoHolding

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack {
                Text(holding.symbol.uppercased())
                    .font(.headline)
                    .foregroundStyle(Color.appPrimaryForeground)
            }
            .frame(width: 44, height: 44)
            .background(Color.appChart4)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(holding.name)
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                Text("\(formatNumber(holding.amount)) \(holding.symbol.uppercased())")
                    .font(.caption)
                    .foregroundStyle(Color.appMutedForeground)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text(formatCurrency(holding.currentValue))
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                HStack(spacing: 2) {
                    Image(systemName: holding.profitLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    Text("\(String(format: "%.1f", abs(holding.profitLossPercentage)))%")
                        .font(.caption)
                }
                .foregroundStyle(holding.profitLoss >= 0 ? Color.appChart2 : Color.appChart1)
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
