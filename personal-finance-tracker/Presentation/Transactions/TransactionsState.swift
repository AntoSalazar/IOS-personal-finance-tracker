import Foundation

enum TransactionsState: Equatable {
    case idle
    case loading
    case success([Transaction])
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var transactions: [Transaction] {
        if case .success(let transactions) = self { return transactions }
        return []
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
