import SwiftUI

struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.appForeground)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                }
            }
            .focused($isFocused)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 12)
            .background(Color.appBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .animation(.appFast, value: isFocused)
            .animation(.appFast, value: errorMessage)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.appDestructive)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return Color.appDestructive
        }
        return isFocused ? Color.appRing : Color.appInput
    }
}

#Preview {
    VStack(spacing: 20) {
        AppTextField(
            title: "Email",
            placeholder: "Enter your email",
            text: .constant(""),
            keyboardType: .emailAddress,
            textContentType: .emailAddress
        )

        AppTextField(
            title: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true,
            textContentType: .password
        )

        AppTextField(
            title: "Email with error",
            placeholder: "Enter your email",
            text: .constant("invalid"),
            errorMessage: "Please enter a valid email"
        )
    }
    .padding()
}
