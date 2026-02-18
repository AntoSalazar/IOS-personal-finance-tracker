import SwiftUI

struct RootView: View {
    let container: AppContainer
    @State private var authViewModel: AuthViewModel

    init(container: AppContainer) {
        self.container = container
        _authViewModel = State(initialValue: container.makeAuthViewModel())
    }

    var body: some View {
        Group {
            switch authViewModel.state {
            case .idle, .loading:
                LoadingView(message: "Loading...")

            case .authenticated:
                MainTabView(authViewModel: authViewModel, container: container)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .unauthenticated, .error:
                AuthCoordinator(viewModel: authViewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.appDefault, value: authViewModel.state.isAuthenticated)
        .task {
            await authViewModel.checkSession()
        }
    }
}
