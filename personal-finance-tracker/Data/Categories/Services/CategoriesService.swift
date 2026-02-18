import Foundation

final class CategoriesService: CategoriesRepository {
    private let api: CategoriesAPI

    init(api: CategoriesAPI) {
        self.api = api
    }

    func getAll(type: CategoryType?) async throws -> [Category] {
        let response = try await api.getAll(type: type?.rawValue)
        return response.categories.map { $0.toDomain() }
    }

    func getById(_ id: String) async throws -> Category {
        let dto = try await api.getById(id)
        return dto.toDomain()
    }

    func create(name: String, type: CategoryType, description: String?, color: String?, icon: String?, parentId: String?) async throws -> Category {
        let request = CreateCategoryRequestDTO(
            name: name,
            type: type.rawValue,
            description: description,
            color: color,
            icon: icon,
            parentId: parentId
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func update(id: String, name: String?, type: CategoryType?, description: String?, color: String?, icon: String?, parentId: String?) async throws -> Category {
        let request = UpdateCategoryRequestDTO(
            name: name,
            type: type?.rawValue,
            description: description,
            color: color,
            icon: icon,
            parentId: parentId
        )
        let dto = try await api.update(id: id, request: request)
        return dto.toDomain()
    }

    func delete(id: String) async throws {
        try await api.delete(id: id)
    }
}
