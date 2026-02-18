import SwiftUI

struct MainTabView: View {
    @Bindable var authViewModel: AuthViewModel
    let container: AppContainer
    @State private var selectedTab: AppTab = .home
    @State private var badges: [AppTab: Int] = [:]

    // ViewModels
    @State private var accountsViewModel: AccountsViewModel?
    @State private var transactionsViewModel: TransactionsViewModel?
    @State private var categoriesViewModel: CategoriesViewModel?
    @State private var subscriptionsViewModel: SubscriptionsViewModel?
    @State private var debtsViewModel: DebtsViewModel?
    @State private var cryptoViewModel: CryptoViewModel?
    @State private var statisticsViewModel: StatisticsViewModel?

    var body: some View {
        VStack(spacing: 0) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        authViewModel: authViewModel,
                        transactionsViewModel: transactionsVM,
                        statisticsViewModel: statisticsVM,
                        accounts: accountsVM.state.accounts,
                        categories: categoriesVM.categories
                    )
                case .accounts:
                    AccountsView(viewModel: accountsVM)
                case .transactions:
                    TransactionsView(
                        viewModel: transactionsVM,
                        accounts: accountsVM.state.accounts,
                        categories: categoriesVM.categories
                    )
                case .stats:
                    StatsView(
                        statisticsViewModel: statisticsVM,
                        cryptoViewModel: cryptoVM
                    )
                case .settings:
                    SettingsView(
                        authViewModel: authViewModel,
                        categoriesViewModel: categoriesVM,
                        exportAPI: container.exportAPI
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            AppTabBar(selectedTab: $selectedTab, badges: badges)
        }
        .ignoresSafeArea(.keyboard)
        .task {
            await categoriesVM.loadCategories()
        }
    }

    // MARK: - Lazy ViewModel Access

    private var accountsVM: AccountsViewModel {
        if let vm = accountsViewModel { return vm }
        let vm = container.makeAccountsViewModel()
        Task { @MainActor in accountsViewModel = vm }
        return vm
    }

    private var transactionsVM: TransactionsViewModel {
        if let vm = transactionsViewModel { return vm }
        let vm = container.makeTransactionsViewModel()
        Task { @MainActor in transactionsViewModel = vm }
        return vm
    }

    private var categoriesVM: CategoriesViewModel {
        if let vm = categoriesViewModel { return vm }
        let vm = container.makeCategoriesViewModel()
        Task { @MainActor in categoriesViewModel = vm }
        return vm
    }

    private var subscriptionsVM: SubscriptionsViewModel {
        if let vm = subscriptionsViewModel { return vm }
        let vm = container.makeSubscriptionsViewModel()
        Task { @MainActor in subscriptionsViewModel = vm }
        return vm
    }

    private var debtsVM: DebtsViewModel {
        if let vm = debtsViewModel { return vm }
        let vm = container.makeDebtsViewModel()
        Task { @MainActor in debtsViewModel = vm }
        return vm
    }

    private var cryptoVM: CryptoViewModel {
        if let vm = cryptoViewModel { return vm }
        let vm = container.makeCryptoViewModel()
        Task { @MainActor in cryptoViewModel = vm }
        return vm
    }

    private var statisticsVM: StatisticsViewModel {
        if let vm = statisticsViewModel { return vm }
        let vm = container.makeStatisticsViewModel()
        Task { @MainActor in statisticsViewModel = vm }
        return vm
    }
}
