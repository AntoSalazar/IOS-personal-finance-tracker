import SwiftUI

struct SettingsView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                List {
                    // Profile Section
                    Section {
                        if let user = authViewModel.state.currentUser {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.appPrimary)
                                
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundStyle(Color.appForeground)
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appMutedForeground)
                                }
                            }
                            .padding(.vertical, AppSpacing.sm)
                        }
                    }
                    
                    // Preferences Section
                    Section("Preferences") {
                        SettingsRow(icon: "bell.fill", title: "Notifications", color: .appChart1)
                        SettingsRow(icon: "paintbrush.fill", title: "Appearance", color: .appChart2)
                        SettingsRow(icon: "globe", title: "Currency", subtitle: "USD", color: .appChart3)
                        SettingsRow(icon: "lock.fill", title: "Privacy", color: .appChart4)
                    }
                    
                    // Data Section
                    Section("Data") {
                        SettingsRow(icon: "arrow.down.doc.fill", title: "Export Data", color: .appPrimary)
                        SettingsRow(icon: "arrow.up.doc.fill", title: "Import Data", color: .appPrimary)
                        SettingsRow(icon: "icloud.fill", title: "Backup & Sync", color: .appChart2)
                    }
                    
                    // Support Section
                    Section("Support") {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", color: .appMutedForeground)
                        SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .appMutedForeground)
                        SettingsRow(icon: "star.fill", title: "Rate App", color: .appChart4)
                    }
                    
                    // Sign Out Section
                    Section {
                        Button(role: .destructive) {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundStyle(Color.appDestructive)
                        }
                    }
                    
                    // Version
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.appMutedForeground)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(Color.appMutedForeground)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(title)
                .foregroundStyle(Color.appForeground)
            
            Spacer()
            
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color.appMutedForeground)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appMutedForeground)
        }
    }
}

#Preview {
    @Previewable @State var mockViewModel = AuthViewModel(
        signInUseCase: SignInUseCase(repository: MockSettingsAuthRepository()),
        signUpUseCase: SignUpUseCase(repository: MockSettingsAuthRepository()),
        signOutUseCase: SignOutUseCase(repository: MockSettingsAuthRepository()),
        getSessionUseCase: GetSessionUseCase(repository: MockSettingsAuthRepository())
    )
    
    return SettingsView(authViewModel: mockViewModel)
}

// MARK: - Mock for Preview

private final class MockSettingsAuthRepository: AuthRepository {
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
