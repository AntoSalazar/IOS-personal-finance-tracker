import Foundation

protocol StatisticsRepository {
    func getStatistics(period: String) async throws -> FinancialStatistics
}
