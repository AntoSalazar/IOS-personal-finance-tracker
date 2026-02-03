import SwiftUI

enum AuthScreen {
    case login
    case register
}

struct AuthCoordinator: View {
    @Bindable var viewModel: AuthViewModel
    @State private var currentScreen: AuthScreen = .login

    var body: some View {
        Group {
            switch currentScreen {
            case .login:
                LoginView(viewModel: viewModel) {
                    withAnimation(.appDefault) {
                        currentScreen = .register
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .register:
                RegisterView(viewModel: viewModel) {
                    withAnimation(.appDefault) {
                        currentScreen = .login
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
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

    return AuthCoordinator(viewModel: mockViewModel)
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
