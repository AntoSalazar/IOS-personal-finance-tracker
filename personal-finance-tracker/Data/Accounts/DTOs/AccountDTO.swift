import Foundation

struct AccountDTO: Codable {
    let id: String
    let name: String
    let type: String
    let balance: Double
    let currency: String
    let description: String?
    let isActive: Bool?

    func toDomain() -> Account {
        Account(
            id: id,
            name: name,
            type: AccountType(rawValue: type) ?? .other,
            balance: balance,
            currency: currency,
            description: description,
            isActive: isActive ?? true
        )
    }
}

struct AccountsResponseDTO: Codable {
    let accounts: [AccountDTO]
    let totalBalance: Double
}

struct CreateAccountRequestDTO: Encodable {
    let name: String
    let type: String
    let balance: Double
    let currency: String
    let description: String?
}

struct UpdateAccountRequestDTO: Encodable {
    let name: String?
    let type: String?
    let balance: Double?
    let currency: String?
    let description: String?
    let isActive: Bool?
}
