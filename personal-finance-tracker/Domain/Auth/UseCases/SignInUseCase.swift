import Foundation

struct SignInUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> AuthSession {
        guard !email.isEmpty else {
            throw AuthValidationError.emptyEmail
        }

        guard email.contains("@") else {
            throw AuthValidationError.invalidEmail
        }

        guard !password.isEmpty else {
            throw AuthValidationError.emptyPassword
        }

        let credentials = SignInCredentials(email: email, password: password)
        return try await repository.signIn(credentials: credentials)
    }
}

enum AuthValidationError: LocalizedError {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case passwordTooShort
    case emptyName

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email is required"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .emptyPassword:
            return "Password is required"
        case .passwordTooShort:
            return "Password must be at least 8 characters"
        case .emptyName:
            return "Name is required"
        }
    }
}
