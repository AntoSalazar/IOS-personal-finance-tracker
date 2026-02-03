import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    let onNavigateToLogin: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case email
        case password
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appMuted.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Header with glass effect
                    GlassEffectContainer {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(Color.appPrimary)
                                .padding(AppSpacing.lg)
                                .glassEffect(.regular, in: .circle)

                            Text("Create an account")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color.appForeground)

                            Text("Enter your details to get started")
                                .font(.subheadline)
                                .foregroundStyle(Color.appMutedForeground)
                        }
                    }
                    .padding(.top, AppSpacing.xl)

                    // Form Card
                    AppCard {
                        VStack(spacing: AppSpacing.md) {
                            AppTextField(
                                title: "Name",
                                placeholder: "Enter your name",
                                text: $viewModel.name,
                                errorMessage: viewModel.nameError,
                                textContentType: .name
                            )
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }

                            AppTextField(
                                title: "Email",
                                placeholder: "name@example.com",
                                text: $viewModel.email,
                                errorMessage: viewModel.emailError,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }

                            AppTextField(
                                title: "Password",
                                placeholder: "Create a password (min. 8 characters)",
                                text: $viewModel.password,
                                isSecure: true,
                                errorMessage: viewModel.passwordError,
                                textContentType: .newPassword
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { signUp() }

                            if let errorMessage = viewModel.state.errorMessage {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(errorMessage)
                                }
                                .font(.caption)
                                .foregroundStyle(Color.appDestructive)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, AppSpacing.xs)
                            }

                            AppButton(
                                title: "Create Account",
                                icon: "person.badge.plus",
                                variant: .glass,
                                size: .lg,
                                isLoading: viewModel.state.isLoading,
                                fullWidth: true,
                                action: signUp
                            )
                            .padding(.top, AppSpacing.sm)
                        }
                    }

                    // Terms text
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundStyle(Color.appMutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.md)

                    // Footer with glass pill
                    HStack(spacing: AppSpacing.xs) {
                        Text("Already have an account?")
                            .foregroundStyle(Color.appMutedForeground)

                        Button(action: onNavigateToLogin) {
                            Text("Sign in")
                                .fontWeight(.semibold)
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)
                    }
                    .font(.subheadline)

                    Spacer(minLength: AppSpacing.xxl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    private func signUp() {
        focusedField = nil
        Task {
            await viewModel.signUp()
        }
    }
}

#Preview {
    @Previewable @State var mockViewModel = AuthViewModel(
        signInUseCase: SignInUseCase(repository: MockAuthRepository()),
        signUpUseCase: SignUpUseCase(repository: MockAuthRepository()),
        signOutUseCase: SignOutUseCase(repository: MockAuthRepository()),
        getSessionUseCase: GetSessionUseCase(repository: MockAuthRepository())
    )

    return RegisterView(viewModel: mockViewModel) {
        print("Navigate to login")
    }
}

// MARK: - Mock for Preview

private final class MockAuthRepository: AuthRepository {
    func signIn(credentials: SignInCredentials) async throws -> AuthSession {
        AuthSession(
            user: User(id: "1", email: credentials.email, name: "Test User"),
            session: Session(id: "s1", expiresAt: Date().addingTimeInterval(3600))
        )
    }

    func signUp(credentials: SignUpCredentials) async throws -> AuthSession {
        AuthSession(
            user: User(id: "1", email: credentials.email, name: credentials.name),
            session: Session(id: "s1", expiresAt: Date().addingTimeInterval(3600))
        )
    }

    func signOut() async throws {}

    func getSession() async throws -> AuthSession? { nil }
}
