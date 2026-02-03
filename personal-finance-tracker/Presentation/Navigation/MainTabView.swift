import SwiftUI

struct MainTabView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var selectedTab: AppTab = .home
    @State private var badges: [AppTab: Int] = [:]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(authViewModel: authViewModel)
                case .accounts:
                    AccountsView()
                case .transactions:
                    TransactionsView()
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView(authViewModel: authViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            AppTabBar(selectedTab: $selectedTab, badges: badges)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    @Previewable @State var mockViewModel = AuthViewModel(
        signInUseCase: SignInUseCase(repository: MockPreviewAuthRepository()),
        signUpUseCase: SignUpUseCase(repository: MockPreviewAuthRepository()),
        signOutUseCase: SignOutUseCase(repository: MockPreviewAuthRepository()),
        getSessionUseCase: GetSessionUseCase(repository: MockPreviewAuthRepository())
    )
    
    return MainTabView(authViewModel: mockViewModel)
}

// MARK: - Mock for Preview

private final class MockPreviewAuthRepository: AuthRepository {
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
    
    func getSession() async throws -> AuthSession? {
        AuthSession(
            user: User(id: "1", email: "test@example.com", name: "Test User"),
            session: Session(id: "s1", expiresAt: Date().addingTimeInterval(3600))
        )
    }
}
