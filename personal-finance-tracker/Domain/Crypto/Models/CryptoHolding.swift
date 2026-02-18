import Foundation

struct CryptoHolding: Identifiable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let amount: Double
    let purchasePrice: Double
    let currentPrice: Double?
    let purchaseDate: Date
    let purchaseFee: Double?
    let notes: String?

    var currentValue: Double {
        amount * (currentPrice ?? purchasePrice)
    }

    var purchaseValue: Double {
        amount * purchasePrice + (purchaseFee ?? 0)
    }

    var profitLoss: Double {
        currentValue - purchaseValue
    }

    var profitLossPercentage: Double {
        guard purchaseValue > 0 else { return 0 }
        return (profitLoss / purchaseValue) * 100
    }
}
