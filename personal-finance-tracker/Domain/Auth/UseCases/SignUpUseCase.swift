import Foundation

struct SignUpUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, password: String, name: String) async throws -> AuthSession {
        guard !email.isEmpty else {
            throw AuthValidationError.emptyEmail
        }

        guard email.contains("@") else {
            throw AuthValidationError.invalidEmail
        }

        guard !password.isEmpty else {
            throw AuthValidationError.emptyPassword
        }

        guard password.count >= 8 else {
            throw AuthValidationError.passwordTooShort
        }

        guard !name.isEmpty else {
            throw AuthValidationError.emptyName
        }

        let credentials = SignUpCredentials(email: email, password: password, name: name)
        return try await repository.signUp(credentials: credentials)
    }
}
