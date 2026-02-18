import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: transaction.type.icon)
                .font(.title2)
                .foregroundStyle(amountColor)
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(transaction.description)
                    .font(.headline)
                    .foregroundStyle(Color.appCardForeground)
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xs) {
                    if let category = transaction.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)

                        Text("·")
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                    }

                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.appMutedForeground)
                }
            }

            Spacer()

            Text(formattedAmount)
                .font(.headline)
                .foregroundStyle(amountColor)
        }
    }

    private var amountColor: Color {
        switch transaction.type {
        case .income: return Color.appChart2
        case .expense: return Color.appChart1
        case .transfer: return Color.appChart3
        }
    }

    private var formattedAmount: String {
        let prefix = transaction.type == .income ? "+" : transaction.type == .expense ? "-" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        let value = formatter.string(from: NSNumber(value: abs(transaction.amount))) ?? "$0.00"
        return "\(prefix)\(value)"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: transaction.date)
    }
}
