import SwiftUI

// MARK: - Design Tokens (matching shadcn/Tailwind design system)

extension Color {
    // MARK: - Base Colors

    static let appBackground = Color("Background")
    static let appForeground = Color("Foreground")
    static let appBorder = Color("Border")
    static let appInput = Color("Input")
    static let appRing = Color("Ring")

    // MARK: - Functional Colors

    static let appPrimary = Color("Primary")
    static let appPrimaryForeground = Color("PrimaryForeground")
    static let appSecondary = Color("Secondary")
    static let appSecondaryForeground = Color("SecondaryForeground")
    static let appDestructive = Color("Destructive")
    static let appDestructiveForeground = Color("DestructiveForeground")
    static let appMuted = Color("Muted")
    static let appMutedForeground = Color("MutedForeground")
    static let appAccent = Color("Accent")
    static let appAccentForeground = Color("AccentForeground")

    
    // MARK: - Card Colors

    static let appCard = Color("Card")
    static let appCardForeground = Color("CardForeground")

    // MARK: - Chart Colors

    static let appChart1 = Color("Chart1")
    static let appChart2 = Color("Chart2")
    static let appChart3 = Color("Chart3")
    static let appChart4 = Color("Chart4")
    static let appChart5 = Color("Chart5")
}

// MARK: - Radius Tokens

enum AppRadius {
    static let base: CGFloat = 10 // 0.625rem
    static let sm: CGFloat = base - 4
    static let md: CGFloat = base - 2
    static let lg: CGFloat = base
    static let xl: CGFloat = base + 4
}

// MARK: - Spacing Tokens

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Animation Tokens

extension Animation {
    static let appDefault = Animation.easeInOut(duration: 0.5)
    static let appFast = Animation.easeInOut(duration: 0.2)
    static let appSlow = Animation.easeInOut(duration: 0.8)
}
