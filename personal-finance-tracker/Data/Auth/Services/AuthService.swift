import Foundation

final class AuthService: AuthRepository {
    private let api: AuthAPI
    private let tokenStorage: TokenStorage

    init(api: AuthAPI, tokenStorage: TokenStorage = .shared) {
        self.api = api
        self.tokenStorage = tokenStorage
    }

    func signIn(credentials: SignInCredentials) async throws -> AuthSession {
        Logger.debug("Attempting sign in for: \(credentials.email)", category: .auth)

        let request = SignInRequestDTO(
            email: credentials.email,
            password: credentials.password
        )

        let response = try await api.signIn(request: request)

        // Store the token securely in Keychain
        tokenStorage.saveToken(response.token)

        Logger.info("Sign in successful for user: \(response.user.id)", category: .auth)

        return response.toDomain()
    }

    func signUp(credentials: SignUpCredentials) async throws -> AuthSession {
        Logger.debug("Attempting sign up for: \(credentials.email)", category: .auth)

        let request = SignUpRequestDTO(
            email: credentials.email,
            password: credentials.password,
            name: credentials.name
        )

        let response = try await api.signUp(request: request)

        // Store the token securely in Keychain
        tokenStorage.saveToken(response.token)

        Logger.info("Sign up successful for user: \(response.user.id)", category: .auth)

        return response.toDomain()
    }

    func signOut() async throws {
        Logger.debug("Signing out", category: .auth)

        do {
            try await api.signOut()
        } catch {
            Logger.warning("Sign out API call failed: \(error)", category: .auth)
        }

        // Clear stored token from Keychain
        tokenStorage.clearToken()

        Logger.info("Sign out successful", category: .auth)
    }

    func getSession() async throws -> AuthSession? {
        Logger.debug("Fetching current session", category: .auth)

        guard tokenStorage.getToken() != nil else {
            Logger.debug("No stored token, user is not authenticated", category: .auth)
            return nil
        }

        do {
            let response = try await api.getSession()
            Logger.info("Session found for user: \(response.user.id)", category: .auth)
            return response.toDomain()
        } catch let error as NetworkError {
            if case .unauthorized = error {
                Logger.debug("Session expired or invalid", category: .auth)
                tokenStorage.clearToken()
                return nil
            }
            throw error
        }
    }
}

// MARK: - Token Storage (Keychain-backed)

final class TokenStorage {
    static let shared = TokenStorage()

    private let keychain = KeychainService.shared
    private let tokenKey = "auth_token"

    func saveToken(_ token: String) {
        do {
            try keychain.save(token, for: tokenKey)
            Logger.debug("Token saved to Keychain", category: .auth)
        } catch {
            Logger.error("Failed to save token to Keychain: \(error)", category: .auth)
        }
    }

    func getToken() -> String? {
        do {
            return try keychain.loadString(for: tokenKey)
        } catch KeychainError.itemNotFound {
            return nil
        } catch {
            Logger.error("Failed to load token from Keychain: \(error)", category: .auth)
            return nil
        }
    }

    func clearToken() {
        keychain.delete(for: tokenKey)
        Logger.debug("Token cleared from Keychain", category: .auth)
    }
}
