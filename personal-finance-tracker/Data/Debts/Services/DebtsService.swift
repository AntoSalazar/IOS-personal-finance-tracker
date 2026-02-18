import Foundation

final class DebtsService: DebtsRepository {
    private let api: DebtsAPI

    init(api: DebtsAPI) {
        self.api = api
    }

    func getAll(isPaid: Bool?) async throws -> [Debt] {
        let response = try await api.getAll(isPaid: isPaid)
        return response.debts.map { $0.toDomain() }
    }

    func getById(_ id: String) async throws -> Debt {
        let dto = try await api.getById(id)
        return dto.toDomain()
    }

    func create(personName: String, amount: Double, description: String?, dueDate: Date?, notes: String?) async throws -> Debt {
        let request = CreateDebtRequestDTO(
            personName: personName,
            amount: amount,
            description: description,
            dueDate: dueDate,
            notes: notes
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func update(id: String, personName: String?, amount: Double?, description: String?, dueDate: Date?, notes: String?) async throws -> Debt {
        let request = UpdateDebtRequestDTO(
            personName: personName,
            amount: amount,
            description: description,
            dueDate: dueDate,
            notes: notes
        )
        let dto = try await api.update(id: id, request: request)
        return dto.toDomain()
    }

    func delete(id: String) async throws {
        try await api.delete(id: id)
    }

    func markAsPaid(id: String, accountId: String, categoryId: String) async throws -> Debt {
        let dto = try await api.markAsPaid(id: id, accountId: accountId, categoryId: categoryId)
        return dto.toDomain()
    }

    func getSummary() async throws -> DebtSummary {
        let dto = try await api.getSummary()
        return dto.toDomain()
    }
}
