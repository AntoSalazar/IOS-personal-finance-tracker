import Foundation

protocol CategoriesRepository {
    func getAll(type: CategoryType?) async throws -> [Category]
    func getById(_ id: String) async throws -> Category
    func create(name: String, type: CategoryType, description: String?, color: String?, icon: String?, parentId: String?) async throws -> Category
    func update(id: String, name: String?, type: CategoryType?, description: String?, color: String?, icon: String?, parentId: String?) async throws -> Category
    func delete(id: String) async throws
}
