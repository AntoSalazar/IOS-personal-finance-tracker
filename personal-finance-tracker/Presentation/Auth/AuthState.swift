import Foundation

enum AuthState: Equatable {
    case idle
    case loading
    case authenticated(User)
    case unauthenticated
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var currentUser: User? {
        if case .authenticated(let user) = self { return user }
        return nil
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
