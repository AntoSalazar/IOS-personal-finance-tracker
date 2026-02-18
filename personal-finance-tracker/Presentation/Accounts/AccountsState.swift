import Foundation

enum AccountsState: Equatable {
    case idle
    case loading
    case success([Account], totalBalance: Double)
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var accounts: [Account] {
        if case .success(let accounts, _) = self { return accounts }
        return []
    }

    var totalBalance: Double {
        if case .success(_, let balance) = self { return balance }
        return 0
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
