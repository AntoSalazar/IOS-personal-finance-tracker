import Foundation

protocol CryptoRepository {
    func getPortfolio() async throws -> [CryptoHolding]
    func create(symbol: String, name: String, amount: Double, purchasePrice: Double, purchaseDate: Date, purchaseFee: Double?, notes: String?) async throws -> CryptoHolding
    func sell(id: String, salePrice: Double, saleDate: Date, saleFee: Double?, saleAccountId: String?, categoryId: String?) async throws
    func updatePrices() async throws -> [CryptoHolding]
}
