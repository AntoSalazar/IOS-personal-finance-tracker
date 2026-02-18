import Foundation
import Observation

@Observable
@MainActor
final class CategoriesViewModel {
    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let repository: CategoriesRepository

    init(repository: CategoriesRepository) {
        self.repository = repository
    }

    func loadCategories(type: CategoryType? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await repository.getAll(type: type)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load categories: \(error)", category: .network)
        }

        isLoading = false
    }

    func createCategory(name: String, type: CategoryType, description: String? = nil, color: String? = nil, icon: String? = nil, parentId: String? = nil) async -> Bool {
        do {
            let category = try await repository.create(
                name: name,
                type: type,
                description: description,
                color: color,
                icon: icon,
                parentId: parentId
            )
            categories.append(category)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateCategory(id: String, name: String? = nil, type: CategoryType? = nil, description: String? = nil, color: String? = nil, icon: String? = nil, parentId: String? = nil) async -> Bool {
        do {
            let updated = try await repository.update(
                id: id,
                name: name,
                type: type,
                description: description,
                color: color,
                icon: icon,
                parentId: parentId
            )
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index] = updated
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteCategory(id: String) async -> Bool {
        do {
            try await repository.delete(id: id)
            categories.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func categoriesForType(_ type: CategoryType) -> [Category] {
        categories.filter { $0.type == type }
    }
}
