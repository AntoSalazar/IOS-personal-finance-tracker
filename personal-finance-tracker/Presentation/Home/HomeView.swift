import SwiftUI

struct HomeView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Welcome message
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(Color.appPrimary)
                                .padding(AppSpacing.lg)
                                .background(Color.appSecondary)
                                .clipShape(Circle())

                            if let user = authViewModel.state.currentUser {
                                Text("Welcome, \(user.name)!")
                                    .font(.title.bold())
                                    .foregroundStyle(Color.appForeground)

                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, AppSpacing.xs)
                                    .background(Color.appSecondary)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, AppSpacing.xl)

                        // Quick Stats
                        HStack(spacing: AppSpacing.md) {
                            QuickStatCard(
                                title: "Income",
                                value: "$0.00",
                                icon: "arrow.down.circle.fill",
                                color: Color.appChart2
                            )
                            
                            QuickStatCard(
                                title: "Expenses",
                                value: "$0.00",
                                icon: "arrow.up.circle.fill",
                                color: Color.appChart1
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Dashboard card
                        AppCard {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                HStack {
                                    Image(systemName: "square.grid.2x2")
                                        .font(.title2)
                                        .foregroundStyle(Color.appPrimary)
                                    Text("Your Dashboard")
                                        .font(.headline)
                                        .foregroundStyle(Color.appCardForeground)
                                }

                                Text("This is where your financial overview will appear. Start by adding your first transaction.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)

                                AppButton(
                                    title: "Add Transaction",
                                    icon: "plus.circle.fill",
                                    variant: .primary,
                                    fullWidth: true
                                ) {
                                    // TODO: Navigate to add transaction
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        // Recent Transactions
                        AppCard {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                HStack {
                                    Text("Recent Transactions")
                                        .font(.headline)
                                        .foregroundStyle(Color.appCardForeground)
                                    Spacer()
                                    Button("See All") {}
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.appPrimary)
                                }

                                Text("No transactions yet")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMutedForeground)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, AppSpacing.lg)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.lg)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Quick Stat Card

private struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Spacer()
                }
                
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appCardForeground)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.appMutedForeground)
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

    return HomeView(authViewModel: mockViewModel)
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

    func getSession() async throws -> AuthSession? {
        AuthSession(
            user: User(id: "1", email: "test@example.com", name: "Test User"),
            session: Session(id: "s1", expiresAt: Date().addingTimeInterval(3600))
        )
    }
}
