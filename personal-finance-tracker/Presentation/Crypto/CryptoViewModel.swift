import Foundation
import Observation

@Observable
@MainActor
final class CryptoViewModel {
    private(set) var holdings: [CryptoHolding] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var showAddHolding = false

    private let repository: CryptoRepository

    init(repository: CryptoRepository) {
        self.repository = repository
    }

    var totalValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }

    var totalProfitLoss: Double {
        holdings.reduce(0) { $0 + $1.profitLoss }
    }

    func loadPortfolio() async {
        isLoading = true
        errorMessage = nil

        do {
            holdings = try await repository.getPortfolio()
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Failed to load crypto portfolio: \(error)", category: .network)
        }

        isLoading = false
    }

    func createHolding(symbol: String, name: String, amount: Double, purchasePrice: Double, purchaseDate: Date, purchaseFee: Double? = nil, notes: String? = nil) async -> Bool {
        do {
            _ = try await repository.create(
                symbol: symbol,
                name: name,
                amount: amount,
                purchasePrice: purchasePrice,
                purchaseDate: purchaseDate,
                purchaseFee: purchaseFee,
                notes: notes
            )
            await loadPortfolio()
            return true
        } catch {
            Logger.error("Failed to create crypto holding: \(error)", category: .network)
            return false
        }
    }

    func sellHolding(id: String, salePrice: Double, saleDate: Date = Date(), saleFee: Double? = nil, saleAccountId: String? = nil, categoryId: String? = nil) async -> Bool {
        do {
            try await repository.sell(
                id: id,
                salePrice: salePrice,
                saleDate: saleDate,
                saleFee: saleFee,
                saleAccountId: saleAccountId,
                categoryId: categoryId
            )
            await loadPortfolio()
            return true
        } catch {
            Logger.error("Failed to sell crypto: \(error)", category: .network)
            return false
        }
    }

    func refreshPrices() async {
        do {
            holdings = try await repository.updatePrices()
        } catch {
            Logger.error("Failed to update crypto prices: \(error)", category: .network)
        }
    }
}
