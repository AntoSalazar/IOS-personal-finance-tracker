import Foundation
import Observation

@Observable
final class AppContainer {
    // MARK: - Auth

    let authRepository: AuthRepository
    let signInUseCase: SignInUseCase
    let signUpUseCase: SignUpUseCase
    let signOutUseCase: SignOutUseCase
    let getSessionUseCase: GetSessionUseCase

    init() {
        // Auth
        let authAPI = AuthAPI()
        let authService = AuthService(api: authAPI)
        self.authRepository = authService
        self.signInUseCase = SignInUseCase(repository: authService)
        self.signUpUseCase = SignUpUseCase(repository: authService)
        self.signOutUseCase = SignOutUseCase(repository: authService)
        self.getSessionUseCase = GetSessionUseCase(repository: authService)
    }

    // MARK: - ViewModel Factories

    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            signOutUseCase: signOutUseCase,
            getSessionUseCase: getSessionUseCase
        )
    }
}
