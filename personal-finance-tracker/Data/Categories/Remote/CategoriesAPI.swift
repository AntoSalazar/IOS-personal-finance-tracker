import Foundation

final class CategoriesAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getAll(type: String? = nil) async throws -> CategoriesResponseDTO {
        var queryItems: [URLQueryItem]? = nil
        if let type {
            queryItems = [URLQueryItem(name: "type", value: type)]
        }
        return try await client.request(endpoint: "categories", queryItems: queryItems)
    }

    func getById(_ id: String) async throws -> CategoryDTO {
        try await client.request(endpoint: "categories/\(id)")
    }

    func create(request: CreateCategoryRequestDTO) async throws -> CategoryDTO {
        try await client.post(endpoint: "categories", body: request)
    }

    func update(id: String, request: UpdateCategoryRequestDTO) async throws -> CategoryDTO {
        try await client.put(endpoint: "categories/\(id)", body: request)
    }

    func delete(id: String) async throws {
        try await client.delete(endpoint: "categories/\(id)")
    }
}
