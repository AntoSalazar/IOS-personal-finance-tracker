import SwiftUI

// MARK: - Tab Definition

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case accounts
    case transactions
    case stats
    case settings
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .accounts: return "Accounts"
        case .transactions: return "Transactions"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .accounts: return "creditcard"
        case .transactions: return "arrow.left.arrow.right.circle"
        case .stats: return "chart.bar"
        case .settings: return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .accounts: return "creditcard.fill"
        case .transactions: return "arrow.left.arrow.right.circle.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Tab Bar

struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    var badges: [AppTab: Int] = [:]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                AppTabItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badgeCount: badges[tab] ?? 0
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    triggerHapticFeedback()
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
        .background(
            Color.appCard
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.appBorder),
            alignment: .top
        )
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Tab Item

private struct AppTabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .symbolRenderingMode(.hierarchical)
                    
                    // Badge
                    if badgeCount > 0 {
                        BadgeView(count: badgeCount)
                            .offset(x: 8, y: -4)
                    }
                }
                .frame(height: 24)
                
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(isSelected ? Color.appPrimary : Color.appMutedForeground)
            .frame(maxWidth: .infinity)
            .frame(height: 52) // 44pt minimum + padding for label
            .contentShape(Rectangle()) // Ensure full area is tappable
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(TabButtonStyle(isPressed: $isPressed))
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Badge View

private struct BadgeView: View {
    let count: Int
    
    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.appDestructive)
            .clipShape(Capsule())
    }
}

// MARK: - Custom Button Style for Press Animation

private struct TabButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = newValue
                }
            }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedTab: AppTab = .home
    
    VStack {
        Spacer()
        Text("Selected: \(selectedTab.title)")
        Spacer()
        AppTabBar(
            selectedTab: $selectedTab,
            badges: [.transactions: 3, .settings: 1]
        )
    }
    .background(Color.appBackground)
}
