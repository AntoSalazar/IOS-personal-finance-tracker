import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    let onNavigateToRegister: () -> Void

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.appPrimary)
                            .padding(AppSpacing.lg)
                            .background(Color.appSecondary)
                            .clipShape(Circle())

                        Text("Welcome back")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.appForeground)

                        Text("Sign in to your account to continue")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)
                    }
                    .padding(.top, AppSpacing.xxl)

                    // Form Card
                    AppCard {
                        VStack(spacing: AppSpacing.md) {
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
                                placeholder: "Enter your password",
                                text: $viewModel.password,
                                isSecure: true,
                                errorMessage: viewModel.passwordError,
                                textContentType: .password
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { signIn() }

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
                                title: "Sign In",
                                icon: "arrow.right",
                                variant: .primary,
                                size: .lg,
                                isLoading: viewModel.state.isLoading,
                                fullWidth: true,
                                action: signIn
                            )
                            .padding(.top, AppSpacing.sm)
                        }
                    }

                    // Footer
                    HStack(spacing: AppSpacing.xs) {
                        Text("Don't have an account?")
                            .foregroundStyle(Color.appMutedForeground)

                        Button(action: onNavigateToRegister) {
                            Text("Sign up")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appPrimary)
                        }
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

    private func signIn() {
        focusedField = nil
        Task {
            await viewModel.signIn()
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

    return LoginView(viewModel: mockViewModel) {
        print("Navigate to register")
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
