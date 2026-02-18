import Foundation

struct Account: Identifiable, Equatable {
    let id: String
    let name: String
    let type: AccountType
    let balance: Double
    let currency: String
    let description: String?
    let isActive: Bool
}
