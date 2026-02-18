import SwiftUI

struct DebtRow: View {
    let debt: Debt

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: debt.isPaid ? "checkmark.circle.fill" : "person.circle.fill")
                .font(.title2)
                .foregroundStyle(debt.isPaid ? Color.appChart2 : Color.appChart1)
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(debt.personName)
                        .font(.headline)
                        .foregroundStyle(Color.appCardForeground)

                    if debt.isPaid {
                        Text("Paid")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.appChart2)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 2)
                            .background(Color.appChart2.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: AppSpacing.sm) {
                    if let desc = debt.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(Color.appMutedForeground)
                            .lineLimit(1)
                    }

                    if let dueDate = debt.dueDate {
                        Text("Due: \(formattedDate(dueDate))")
                            .font(.caption)
                            .foregroundStyle(isOverdue(dueDate) ? Color.appDestructive : Color.appMutedForeground)
                    }
                }
            }

            Spacer()

            Text(formattedAmount)
                .font(.headline)
                .foregroundStyle(debt.isPaid ? Color.appMutedForeground : Color.appChart1)
        }
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: debt.amount)) ?? "$0.00"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func isOverdue(_ date: Date) -> Bool {
        !debt.isPaid && date < Date()
    }
}
