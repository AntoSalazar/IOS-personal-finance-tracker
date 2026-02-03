import SwiftUI

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color.appDestructive)

            Text("Something went wrong")
                .font(.headline)
                .foregroundStyle(Color.appForeground)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let retryAction {
                AppButton(
                    title: "Try Again",
                    icon: "arrow.clockwise",
                    variant: .outline,
                    action: retryAction
                )
                .padding(.top, AppSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ErrorView(message: "Failed to load data. Please check your connection and try again.") {
        print("Retry tapped")
    }
}
