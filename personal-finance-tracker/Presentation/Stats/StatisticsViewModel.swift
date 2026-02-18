import Foundation
import Observation

@Observable
@MainActor
final class StatisticsViewModel {
    // Stats page data (period-dependent)
    private(set) var statistics: FinancialStatistics?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var selectedPeriod: String = "month"

    // Home page data (always current month)
    private(set) var homeStatistics: FinancialStatistics?
    private(set) var isLoadingHome = false

    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func loadStatistics() async {
        isLoading = true
        errorMessage = nil

        do {
            statistics = try await repository.getStatistics(period: selectedPeriod)
        } catch is CancellationError {
            // Task cancelled due to navigation, ignore
        } catch let error as URLError where error.code == .cancelled {
            // Network request cancelled due to navigation, ignore
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load statistics: \(error)", category: .network)
        }

        isLoading = false
    }

    func loadHomeStatistics() async {
        isLoadingHome = true

        do {
            homeStatistics = try await repository.getStatistics(period: "all")
        } catch is CancellationError {
            // Ignore
        } catch let error as URLError where error.code == .cancelled {
            // Ignore
        } catch {
            Logger.error("Failed to load home statistics: \(error)", category: .network)
        }

        isLoadingHome = false
    }

    func changePeriod(_ period: String) {
        selectedPeriod = period
        Task { await loadStatistics() }
    }
}
