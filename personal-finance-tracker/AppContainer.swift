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

    // MARK: - Repositories

    let categoriesRepository: CategoriesRepository
    let accountsRepository: AccountsRepository
    let transactionsRepository: TransactionsRepository
    let subscriptionsRepository: SubscriptionsRepository
    let debtsRepository: DebtsRepository
    let cryptoRepository: CryptoRepository
    let statisticsRepository: StatisticsRepository

    // MARK: - Export

    let exportAPI: ExportAPI

    init() {
        // Auth
        let authAPI = AuthAPI()
        let authService = AuthService(api: authAPI)
        self.authRepository = authService
        self.signInUseCase = SignInUseCase(repository: authService)
        self.signUpUseCase = SignUpUseCase(repository: authService)
        self.signOutUseCase = SignOutUseCase(repository: authService)
        self.getSessionUseCase = GetSessionUseCase(repository: authService)

        // Categories
        let categoriesAPI = CategoriesAPI()
        self.categoriesRepository = CategoriesService(api: categoriesAPI)

        // Accounts
        let accountsAPI = AccountsAPI()
        self.accountsRepository = AccountsService(api: accountsAPI)

        // Transactions
        let transactionsAPI = TransactionsAPI()
        self.transactionsRepository = TransactionsService(api: transactionsAPI)

        // Subscriptions
        let subscriptionsAPI = SubscriptionsAPI()
        self.subscriptionsRepository = SubscriptionsService(api: subscriptionsAPI)

        // Debts
        let debtsAPI = DebtsAPI()
        self.debtsRepository = DebtsService(api: debtsAPI)

        // Crypto
        let cryptoAPI = CryptoAPI()
        self.cryptoRepository = CryptoService(api: cryptoAPI)

        // Statistics
        let statisticsAPI = StatisticsAPI()
        self.statisticsRepository = StatisticsService(api: statisticsAPI)

        // Export
        self.exportAPI = ExportAPI()
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

    @MainActor
    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(repository: categoriesRepository)
    }

    @MainActor
    func makeAccountsViewModel() -> AccountsViewModel {
        AccountsViewModel(repository: accountsRepository)
    }

    @MainActor
    func makeTransactionsViewModel() -> TransactionsViewModel {
        TransactionsViewModel(repository: transactionsRepository)
    }

    @MainActor
    func makeSubscriptionsViewModel() -> SubscriptionsViewModel {
        SubscriptionsViewModel(repository: subscriptionsRepository)
    }

    @MainActor
    func makeDebtsViewModel() -> DebtsViewModel {
        DebtsViewModel(repository: debtsRepository)
    }

    @MainActor
    func makeCryptoViewModel() -> CryptoViewModel {
        CryptoViewModel(repository: cryptoRepository)
    }

    @MainActor
    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(repository: statisticsRepository)
    }
}
