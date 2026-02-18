import Foundation

final class StatisticsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getStatistics(period: String) async throws -> StatisticsDTO {
        try await client.request(
            endpoint: "statistics",
            queryItems: [URLQueryItem(name: "period", value: period)]
        )
    }
}
