import SwiftUI

struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: account.type.icon)
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(account.name)
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)

                Text(account.type.title)
                    .font(.caption)
                    .foregroundStyle(Color.appMutedForeground)
            }

            Spacer()

            Text(formatCurrency(account.balance, currency: account.currency))
                .font(.headline)
                .foregroundStyle(account.balance >= 0 ? Color.appChart2 : Color.appChart1)
        }
    }

    private func formatCurrency(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
