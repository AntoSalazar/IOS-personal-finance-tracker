import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - GET Request

    func request<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyHeaders(to: &request)

        return try await perform(request)
    }

    // MARK: - POST Request

    func post<T: Decodable, B: Encodable>(
        endpoint: String,
        body: B
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw NetworkError.encodingError(error)
        }

        return try await perform(request)
    }

    // MARK: - POST Request (No Response Body)

    func post<B: Encodable>(
        endpoint: String,
        body: B
    ) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw NetworkError.encodingError(error)
        }

        try await performVoid(request)
    }

    // MARK: - POST Request (Empty Body)

    func post(endpoint: String) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(to: &request)

        try await performVoid(request)
    }

    // MARK: - DELETE Request

    func delete(endpoint: String) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        applyHeaders(to: &request)

        try await performVoid(request)
    }

    // MARK: - Private Helpers

    private func applyHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Required for APIs with CORS protection
        request.setValue(AppConfig.apiBaseURL.absoluteString, forHTTPHeaderField: "Origin")
        // Identify as mobile client
        request.setValue("PersonalFinanceTracker-iOS", forHTTPHeaderField: "X-Client-Platform")
    }

    private func buildURL(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URL {
        var components = URLComponents(
            url: AppConfig.baseAPIURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.error("Decoding error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }

    private func performVoid(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.errorMessage
            )
        }
    }
}
