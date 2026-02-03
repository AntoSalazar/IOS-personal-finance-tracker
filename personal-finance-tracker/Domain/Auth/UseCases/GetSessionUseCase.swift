import Foundation

struct GetSessionUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async throws -> AuthSession? {
        try await repository.getSession()
    }
}
