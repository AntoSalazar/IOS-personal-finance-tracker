import Foundation

final class CryptoService: CryptoRepository {
    private let api: CryptoAPI

    init(api: CryptoAPI) {
        self.api = api
    }

    func getPortfolio() async throws -> [CryptoHolding] {
        let response = try await api.getPortfolio()
        return response.holdings.map { $0.toDomain() }
    }

    func create(symbol: String, name: String, amount: Double, purchasePrice: Double, purchaseDate: Date, purchaseFee: Double?, notes: String?) async throws -> CryptoHolding {
        let request = CreateCryptoRequestDTO(
            symbol: symbol,
            name: name,
            amount: amount,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate,
            purchaseFee: purchaseFee,
            notes: notes
        )
        let dto = try await api.create(request: request)
        return dto.toDomain()
    }

    func sell(id: String, salePrice: Double, saleDate: Date, saleFee: Double?, saleAccountId: String?, categoryId: String?) async throws {
        let request = SellCryptoRequestDTO(
            salePrice: salePrice,
            saleDate: saleDate,
            saleFee: saleFee,
            saleAccountId: saleAccountId,
            categoryId: categoryId
        )
        try await api.sell(id: id, request: request)
    }

    func updatePrices() async throws -> [CryptoHolding] {
        try await api.updatePrices()
        return try await getPortfolio()
    }
}
