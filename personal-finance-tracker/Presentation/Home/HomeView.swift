import SwiftUI

struct HomeView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: AppSpacing.xl) {
                    Spacer()

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

                    Spacer()

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

                    Spacer()

                    // Bottom action bar
                    HStack(spacing: AppSpacing.md) {
                        ActionButton(icon: "house.fill", label: "Home", isSelected: true)
                        ActionButton(icon: "list.bullet.rectangle", label: "Transactions")
                        ActionButton(icon: "chart.bar.fill", label: "Analytics")
                        ActionButton(icon: "gearshape.fill", label: "Settings")
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -4)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.md)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.appForeground)
                    }
                    .padding(AppSpacing.sm)
                    .background(Color.appSecondary)
                    .clipShape(Circle())
                }
            }
            .navigationTitle("Finance Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let icon: String
    let label: String
    var isSelected: Bool = false

    var body: some View {
        Button {
            // TODO: Handle navigation
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? Color.appPrimary : Color.appMutedForeground)
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
