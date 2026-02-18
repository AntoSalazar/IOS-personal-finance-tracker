import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "repeat.circle.fill")
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 44, height: 44)
                .background(Color.appSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(subscription.name)
                        .font(.headline)
                        .foregroundStyle(Color.appCardForeground)

                    StatusBadge(status: subscription.status)
                }

                HStack(spacing: AppSpacing.sm) {
                    Text(subscription.frequency.title)
                        .font(.caption)
                        .foregroundStyle(Color.appMutedForeground)

                    Text("Next: \(formattedDate)")
                        .font(.caption)
                        .foregroundStyle(Color.appMutedForeground)
                }
            }

            Spacer()

            Text(formattedAmount)
                .font(.headline)
                .foregroundStyle(Color.appChart1)
        }
    }

    private var statusColor: Color {
        switch subscription.status {
        case .active: return Color.appChart2
        case .paused: return Color.appChart4
        case .cancelled: return Color.appMutedForeground
        }
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        return formatter.string(from: NSNumber(value: subscription.amount)) ?? "$0.00"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: subscription.nextBillingDate)
    }
}

// MARK: - Status Badge

private struct StatusBadge: View {
    let status: SubscriptionStatus

    var body: some View {
        Text(status.title)
            .font(.caption2.weight(.medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch status {
        case .active: return Color.appChart2
        case .paused: return Color.appChart4
        case .cancelled: return Color.appMutedForeground
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .active: return Color.appChart2.opacity(0.15)
        case .paused: return Color.appChart4.opacity(0.15)
        case .cancelled: return Color.appMutedForeground.opacity(0.15)
        }
    }
}
