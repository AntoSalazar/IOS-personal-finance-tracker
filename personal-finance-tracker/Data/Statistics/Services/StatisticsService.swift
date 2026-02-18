import Foundation

final class StatisticsService: StatisticsRepository {
    private let api: StatisticsAPI

    init(api: StatisticsAPI) {
        self.api = api
    }

    func getStatistics(period: String) async throws -> FinancialStatistics {
        let dto = try await api.getStatistics(period: period)
        return dto.toDomain()
    }
}
