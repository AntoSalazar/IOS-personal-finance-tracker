import Foundation

struct TransactionDTO: Codable {
    let id: String
    let accountId: String
    let amount: Double
    let type: String
    let description: String
    let reason: String?
    let categoryId: String?
    let date: Date
    let createdAt: Date
    let account: TransactionAccountDTO?
    let category: TransactionCategoryDTO?

    func toDomain() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            amount: amount,
            type: TransactionType(rawValue: type) ?? .expense,
            description: description,
            reason: reason,
            categoryId: categoryId,
            date: date,
            createdAt: createdAt,
            account: account?.toDomain(),
            category: category?.toDomain()
        )
    }
}

struct TransactionAccountDTO: Codable {
    let id: String
    let name: String
    let type: String

    func toDomain() -> Account {
        Account(
            id: id,
            name: name,
            type: AccountType(rawValue: type) ?? .other,
            balance: 0,
            currency: "MXN",
            description: nil,
            isActive: true
        )
    }
}

struct TransactionCategoryDTO: Codable {
    let id: String
    let name: String
    let type: String

    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            description: nil,
            color: nil,
            icon: nil,
            type: CategoryType(rawValue: type) ?? .expense,
            parentId: nil
        )
    }
}

struct TransactionsResponseDTO: Codable {
    let transactions: [TransactionDTO]
}

struct CreateTransactionRequestDTO: Encodable {
    let accountId: String
    let amount: Double
    let type: String
    let description: String
    let reason: String?
    let categoryId: String?
    let date: Date
}

struct CreateTransferRequestDTO: Encodable {
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
    let description: String
    let date: Date
}
