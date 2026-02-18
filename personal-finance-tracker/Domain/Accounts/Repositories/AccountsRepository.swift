import Foundation

protocol AccountsRepository {
    func getAll() async throws -> (accounts: [Account], totalBalance: Double)
    func getById(_ id: String) async throws -> Account
    func create(name: String, type: AccountType, balance: Double, currency: String, description: String?) async throws -> Account
    func update(id: String, name: String?, type: AccountType?, balance: Double?, currency: String?, description: String?, isActive: Bool?) async throws -> Account
    func delete(id: String) async throws
}
