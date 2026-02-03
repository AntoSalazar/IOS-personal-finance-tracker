# Design System

This document outlines the design tokens and visual styles used in the Personal Finance Tracker iOS application.

## Tech Stack

- **SwiftUI**: Apple's declarative UI framework
- **Color Space**: OKLCH for perceptible color uniformity
- **Typography**: SF Pro (system font)

---

## Colors

The application uses the **OKLCH color space** for perceptible uniformity, converted to sRGB for SwiftUI compatibility.

### Base Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `Background` | White | Dark Grey (#242424) | Page background |
| `Foreground` | Near Black (#242424) | Near White (#FBFBFB) | Primary text |
| `Border` | Light Grey (#EAEAEA) | White 10% opacity | Borders |
| `Input` | Light Grey (#EAEAEA) | White 15% opacity | Input borders |
| `Ring` | Medium Grey (#B0B0B0) | Dark Grey (#8A8A8A) | Focus rings |

### Functional Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `Primary` | Near Black (#181818) | Near White (#EAEAEA) | Main actions/buttons |
| `PrimaryForeground` | White | Near Black | Primary button text |
| `Secondary` | Light Grey (#F7F7F7) | Dark Grey (#414141) | Secondary actions |
| `SecondaryForeground` | Near Black | Near White | Secondary button text |
| `Destructive` | Red (#DC2626) | Light Red (#EF4444) | Errors/Delete actions |
| `DestructiveForeground` | White | White | Destructive button text |
| `Muted` | Light Grey (#F7F7F7) | Dark Grey (#414141) | Muted backgrounds |
| `MutedForeground` | Medium Grey (#6B6B6B) | Light Grey (#A1A1A1) | Muted text |
| `Accent` | Light Grey (#F7F7F7) | Dark Grey (#414141) | Hover states, accents |
| `AccentForeground` | Near Black | Near White | Accent text |

### Card Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `Card` | White | Dark Grey (#1C1C1E) | Card backgrounds |
| `CardForeground` | Near Black | Near White | Card text |

### Chart Colors

Used for data visualization with distinct, accessible colors:

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| `Chart1` | Orange (#E67E45) | Blue (#4F7CDA) | Primary chart color |
| `Chart2` | Teal (#3B9A8F) | Green (#4DD4AC) | Secondary chart color |
| `Chart3` | Slate (#4A6478) | Yellow (#E8B931) | Tertiary chart color |
| `Chart4` | Gold (#E8C547) | Purple (#A855F7) | Fourth chart color |
| `Chart5` | Amber (#E8B931) | Red (#F06449) | Fifth chart color |

---

## Usage in SwiftUI

Colors are accessed via the `Color` extension:

```swift
// Base colors
Color.appBackground
Color.appForeground
Color.appBorder

// Functional colors
Color.appPrimary
Color.appSecondary
Color.appDestructive
Color.appMuted
Color.appAccent

// Chart colors
Color.appChart1
Color.appChart2
Color.appChart3
Color.appChart4
Color.appChart5
```

---

## Typography

The app uses the system font (SF Pro) for optimal iOS integration.

```swift
// Heading styles
.font(.largeTitle.bold())     // Large titles
.font(.title.bold())          // Section headers
.font(.headline)              // Card titles
.font(.subheadline)           // Descriptions
.font(.body)                  // Body text
.font(.caption)               // Small text
```

---

## Border Radii

Consistent corner radii for a cohesive design:

| Token | Value | Usage |
|-------|-------|-------|
| `AppRadius.base` | 10pt | Base radius |
| `AppRadius.sm` | 6pt | Small elements |
| `AppRadius.md` | 8pt | Medium elements (buttons) |
| `AppRadius.lg` | 10pt | Large elements (cards) |
| `AppRadius.xl` | 14pt | Extra large elements |

```swift
// Usage
.clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
```

---

## Spacing

Consistent spacing tokens based on a 4pt grid:

| Token | Value | Usage |
|-------|-------|-------|
| `AppSpacing.xs` | 4pt | Minimal spacing |
| `AppSpacing.sm` | 8pt | Small spacing |
| `AppSpacing.md` | 16pt | Medium spacing |
| `AppSpacing.lg` | 24pt | Large spacing |
| `AppSpacing.xl` | 32pt | Section spacing |
| `AppSpacing.xxl` | 48pt | Large section spacing |

```swift
// Usage
.padding(AppSpacing.md)
VStack(spacing: AppSpacing.lg) { ... }
```

---

## Animations

Smooth, consistent animations across the app:

| Token | Duration | Curve | Usage |
|-------|----------|-------|-------|
| `Animation.appDefault` | 0.5s | easeInOut | Standard transitions |
| `Animation.appFast` | 0.2s | easeInOut | Quick feedback |
| `Animation.appSlow` | 0.8s | easeInOut | Deliberate transitions |

```swift
// Usage
.animation(.appDefault, value: someValue)
withAnimation(.appFast) { ... }
```

---

## Components

### AppButton

Predefined button variants:

| Variant | Style |
|---------|-------|
| `primary` | Solid primary background |
| `secondary` | Solid secondary background |
| `destructive` | Solid destructive background |
| `outline` | Transparent with border |
| `ghost` | Transparent, no border |
| `link` | Text-only, underlined look |

```swift
AppButton(title: "Submit", variant: .primary) { action() }
AppButton(title: "Cancel", variant: .secondary) { cancel() }
AppButton(title: "Delete", variant: .destructive) { delete() }
```

### AppCard

Container with consistent styling:

```swift
AppCard {
    VStack {
        Text("Card Title")
        Text("Card content here")
    }
}
```

### AppTextField

Styled input field:

```swift
AppTextField(
    title: "Email",
    placeholder: "name@example.com",
    text: $email,
    errorMessage: emailError
)
```

---

## Dark Mode

All colors automatically adapt to the user's system appearance. The app fully supports both light and dark modes with carefully selected color pairs for optimal readability and visual comfort.

---

## Best Practices

1. **Use semantic colors** - Always use `Color.appPrimary` instead of hardcoded colors
2. **Consistent spacing** - Use `AppSpacing` tokens for all margins and padding
3. **Animation consistency** - Use `Animation.app*` tokens for all animations
4. **Border radii** - Use `AppRadius` tokens for consistent rounded corners
5. **Accessibility** - All color combinations meet WCAG contrast requirements
