import Foundation

final class AccountsService: AccountsRepository {
    private let api: AccountsAPI

    init(api: AccountsAPI) {
        self.api = api
    }

    func getAll() async throws -> (accounts: [Account], totalBalance: Double) {
        let response = try await api.getAll()
        let accounts = response.accounts.map { $0.toDomain() }
        return (accounts, response.totalBalance)
    }

    func getById(_ id: String) async throws -> Account {
        let dto = try await api.getById(id)
        return dto.toDomain()
    }

    func create(name: String, type: AccountType, balance: Double, currency: String, description: String?) async throws -> Account {
        let request = CreateAccountRequestDTO(
            name: name,
            type: type.rawValue,
            balance: balance,
            currency: currency,
            description: description
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func update(id: String, name: String?, type: AccountType?, balance: Double?, currency: String?, description: String?, isActive: Bool?) async throws -> Account {
        let request = UpdateAccountRequestDTO(
            name: name,
            type: type?.rawValue,
            balance: balance,
            currency: currency,
            description: description,
            isActive: isActive
        )
        let dto = try await api.update(id: id, request: request)
        return dto.toDomain()
    }

    func delete(id: String) async throws {
        try await api.delete(id: id)
    }
}
