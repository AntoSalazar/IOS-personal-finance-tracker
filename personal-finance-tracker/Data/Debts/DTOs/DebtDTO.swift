import Foundation

struct DebtDTO: Codable {
    let id: String
    let personName: String
    let amount: Double
    let description: String?
    let dueDate: Date?
    let isPaid: Bool
    let paidDate: Date?
    let notes: String?

    func toDomain() -> Debt {
        Debt(
            id: id,
            personName: personName,
            amount: amount,
            description: description,
            dueDate: dueDate,
            isPaid: isPaid,
            paidDate: paidDate,
            notes: notes
        )
    }
}

struct DebtsResponseDTO: Codable {
    let debts: [DebtDTO]
}

struct DebtSummaryDTO: Codable {
    let totalDebts: Int?
    let totalAmount: Double?
    let paidDebts: Int?
    let paidAmount: Double?
    let unpaidDebts: Int?
    let unpaidAmount: Double?

    func toDomain() -> DebtSummary {
        DebtSummary(
            totalDebts: totalDebts ?? 0,
            totalAmount: totalAmount ?? 0,
            paidDebts: paidDebts ?? 0,
            paidAmount: paidAmount ?? 0,
            unpaidDebts: unpaidDebts ?? 0,
            unpaidAmount: unpaidAmount ?? 0
        )
    }
}

struct CreateDebtRequestDTO: Encodable {
    let personName: String
    let amount: Double
    let description: String?
    let dueDate: Date?
    let notes: String?
}

struct UpdateDebtRequestDTO: Encodable {
    let personName: String?
    let amount: Double?
    let description: String?
    let dueDate: Date?
    let notes: String?
}

struct MarkDebtAsPaidRequestDTO: Encodable {
    let accountId: String
    let categoryId: String
    let paidDate: String?
}
