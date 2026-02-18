import Foundation

struct Transaction: Identifiable, Equatable {
    let id: String
    let accountId: String
    let amount: Double
    let type: TransactionType
    let description: String
    let reason: String?
    let categoryId: String?
    let date: Date
    let createdAt: Date
    let account: Account?
    let category: Category?

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
}
