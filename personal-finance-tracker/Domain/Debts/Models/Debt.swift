import Foundation

struct Debt: Identifiable, Equatable {
    let id: String
    let personName: String
    let amount: Double
    let description: String?
    let dueDate: Date?
    let isPaid: Bool
    let paidDate: Date?
    let notes: String?
}
