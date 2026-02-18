import Foundation

struct CategoryDTO: Codable {
    let id: String
    let name: String
    let description: String?
    let color: String?
    let icon: String?
    let type: String
    let parentId: String?

    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            description: description,
            color: color,
            icon: icon,
            type: CategoryType(rawValue: type) ?? .expense,
            parentId: parentId
        )
    }
}

struct CategoriesResponseDTO: Codable {
    let categories: [CategoryDTO]
}

struct CreateCategoryRequestDTO: Encodable {
    let name: String
    let type: String
    let description: String?
    let color: String?
    let icon: String?
    let parentId: String?
}

struct UpdateCategoryRequestDTO: Encodable {
    let name: String?
    let type: String?
    let description: String?
    let color: String?
    let icon: String?
    let parentId: String?
}
