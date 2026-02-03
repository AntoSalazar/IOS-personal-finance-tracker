import Foundation
import Observation

@Observable
@MainActor
final class AuthViewModel {
    private(set) var state: AuthState = .idle

    // Form fields
    var email: String = ""
    var password: String = ""
    var name: String = ""

    // Validation errors
    var emailError: String?
    var passwordError: String?
    var nameError: String?

    private let signInUseCase: SignInUseCase
    private let signUpUseCase: SignUpUseCase
    private let signOutUseCase: SignOutUseCase
    private let getSessionUseCase: GetSessionUseCase

    init(
        signInUseCase: SignInUseCase,
        signUpUseCase: SignUpUseCase,
        signOutUseCase: SignOutUseCase,
        getSessionUseCase: GetSessionUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
        self.getSessionUseCase = getSessionUseCase
    }

    // MARK: - Public Methods

    func checkSession() async {
        state = .loading

        do {
            if let session = try await getSessionUseCase.execute() {
                state = .authenticated(session.user)
            } else {
                state = .unauthenticated
            }
        } catch {
            Logger.error("Session check failed: \(error)", category: .auth)
            state = .unauthenticated
        }
    }

    func signIn() async {
        clearErrors()

        guard validateSignInFields() else { return }

        state = .loading

        do {
            let session = try await signInUseCase.execute(email: email, password: password)
            state = .authenticated(session.user)
            clearForm()
        } catch let error as AuthValidationError {
            handleValidationError(error)
            state = .unauthenticated
        } catch {
            Logger.error("Sign in failed: \(error)", category: .auth)
            state = .error(error.localizedDescription)
        }
    }

    func signUp() async {
        clearErrors()

        guard validateSignUpFields() else { return }

        state = .loading

        do {
            let session = try await signUpUseCase.execute(
                email: email,
                password: password,
                name: name
            )
            state = .authenticated(session.user)
            clearForm()
        } catch let error as AuthValidationError {
            handleValidationError(error)
            state = .unauthenticated
        } catch {
            Logger.error("Sign up failed: \(error)", category: .auth)
            state = .error(error.localizedDescription)
        }
    }

    func signOut() async {
        state = .loading

        do {
            try await signOutUseCase.execute()
            state = .unauthenticated
            clearForm()
        } catch {
            Logger.error("Sign out failed: \(error)", category: .auth)
            state = .error(error.localizedDescription)
        }
    }

    func clearError() {
        if case .error = state {
            state = .unauthenticated
        }
    }

    // MARK: - Private Methods

    private func validateSignInFields() -> Bool {
        var isValid = true

        if email.isEmpty {
            emailError = "Email is required"
            isValid = false
        } else if !email.contains("@") {
            emailError = "Please enter a valid email"
            isValid = false
        }

        if password.isEmpty {
            passwordError = "Password is required"
            isValid = false
        }

        return isValid
    }

    private func validateSignUpFields() -> Bool {
        var isValid = validateSignInFields()

        if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
            isValid = false
        }

        if name.isEmpty {
            nameError = "Name is required"
            isValid = false
        }

        return isValid
    }

    private func handleValidationError(_ error: AuthValidationError) {
        switch error {
        case .emptyEmail, .invalidEmail:
            emailError = error.localizedDescription
        case .emptyPassword, .passwordTooShort:
            passwordError = error.localizedDescription
        case .emptyName:
            nameError = error.localizedDescription
        }
    }

    private func clearErrors() {
        emailError = nil
        passwordError = nil
        nameError = nil
    }

    private func clearForm() {
        email = ""
        password = ""
        name = ""
        clearErrors()
    }
}
