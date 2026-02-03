import SwiftUI

enum AppButtonVariant {
    case primary
    case secondary
    case destructive
    case outline
    case ghost
    case link
    case glass
}

enum AppButtonSize {
    case sm
    case md
    case lg
    case icon

    var height: CGFloat {
        switch self {
        case .sm: return 36
        case .md: return 44
        case .lg: return 52
        case .icon: return 44
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 24
        case .icon: return 0
        }
    }

    var font: Font {
        switch self {
        case .sm: return .subheadline.weight(.medium)
        case .md: return .body.weight(.medium)
        case .lg: return .body.weight(.semibold)
        case .icon: return .body.weight(.medium)
        }
    }
}

struct AppButton: View {
    let title: String
    var icon: String? = nil
    var variant: AppButtonVariant = .primary
    var size: AppButtonSize = .md
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = false
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        if variant == .glass {
            glassButton
        } else {
            standardButton
        }
    }

    private var standardButton: some View {
        Button(action: action) {
            buttonContent
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: size.height)
                .padding(.horizontal, size.horizontalPadding)
                .foregroundStyle(foregroundColor)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(overlay)
        }
        .disabled(isLoading || isDisabled || !isEnabled)
        .opacity(effectiveOpacity)
        .animation(.appFast, value: isLoading)
        .animation(.appFast, value: isDisabled)
    }

    private var glassButton: some View {
        Button(action: action) {
            buttonContent
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: size.height)
                .padding(.horizontal, size.horizontalPadding)
        }
        .disabled(isLoading || isDisabled || !isEnabled)
        .opacity(effectiveOpacity)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .animation(.appFast, value: isLoading)
        .animation(.appFast, value: isDisabled)
    }

    private var buttonContent: some View {
        HStack(spacing: AppSpacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(variant == .glass ? .primary : foregroundColor)
                    .scaleEffect(0.8)
            } else if let icon {
                Image(systemName: icon)
                    .font(size.font)
            }

            if size != .icon {
                Text(title)
                    .font(size.font)
            }
        }
    }

    private var effectiveOpacity: Double {
        (isLoading || isDisabled || !isEnabled) ? 0.5 : 1.0
    }

    @ViewBuilder
    private var background: some View {
        switch variant {
        case .primary:
            Color.appPrimary
        case .secondary:
            Color.appSecondary
        case .destructive:
            Color.appDestructive
        case .outline, .ghost, .link, .glass:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return Color.appPrimaryForeground
        case .secondary:
            return Color.appSecondaryForeground
        case .destructive:
            return Color.appDestructiveForeground
        case .outline:
            return Color.appForeground
        case .ghost:
            return Color.appForeground
        case .link:
            return Color.appPrimary
        case .glass:
            return Color.appForeground
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch variant {
        case .outline:
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(Color.appInput, lineWidth: 1)
        default:
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton(title: "Primary Button", variant: .primary) {}
        AppButton(title: "Secondary", variant: .secondary) {}
        AppButton(title: "Glass Button", icon: "sparkles", variant: .glass) {}
        AppButton(title: "Glass Full Width", variant: .glass, fullWidth: true) {}
        AppButton(title: "Outline", variant: .outline) {}
        AppButton(title: "Loading...", variant: .glass, isLoading: true) {}
    }
    .padding()
}
