import Foundation

struct CryptoHoldingDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let amount: Double
    let purchasePrice: Double
    let currentPrice: Double?
    let purchaseDate: Date
    let purchaseFee: Double?
    let notes: String?

    func toDomain() -> CryptoHolding {
        CryptoHolding(
            id: id,
            symbol: symbol,
            name: name,
            amount: amount,
            purchasePrice: purchasePrice,
            currentPrice: currentPrice,
            purchaseDate: purchaseDate,
            purchaseFee: purchaseFee,
            notes: notes
        )
    }
}

struct CryptoPortfolioResponseDTO: Codable {
    let holdings: [CryptoHoldingDTO]
    let totalValue: Double?
    let totalCost: Double?
    let totalProfitLoss: Double?
    let profitLossPercentage: Double?
}

struct CreateCryptoRequestDTO: Encodable {
    let symbol: String
    let name: String
    let amount: Double
    let purchasePrice: Double
    let purchaseDate: Date
    let purchaseFee: Double?
    let notes: String?
}

struct SellCryptoRequestDTO: Encodable {
    let salePrice: Double
    let saleDate: Date
    let saleFee: Double?
    let saleAccountId: String?
    let categoryId: String?
}
