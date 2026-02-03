import SwiftUI

struct AccountsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Accounts Section
                        SectionCard(
                            title: "Accounts",
                            icon: "creditcard.fill",
                            description: "Manage your bank accounts, wallets, and payment methods"
                        )
                        
                        // Debts Section
                        SectionCard(
                            title: "Debts",
                            icon: "arrow.down.circle.fill",
                            description: "Track loans, credit cards, and money you owe"
                        )
                        
                        // Subscriptions Section
                        SectionCard(
                            title: "Subscriptions",
                            icon: "repeat.circle.fill",
                            description: "Monitor recurring payments and subscriptions"
                        )
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Section Card Component

private struct SectionCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        AppCard {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.appSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.appCardForeground)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.appMutedForeground)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appMutedForeground)
            }
        }
    }
}

#Preview {
    AccountsView()
}
