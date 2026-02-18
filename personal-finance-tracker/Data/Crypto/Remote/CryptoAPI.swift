import Foundation

final class CryptoAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getPortfolio() async throws -> CryptoPortfolioResponseDTO {
        try await client.request(endpoint: "crypto")
    }

    func create(request: CreateCryptoRequestDTO) async throws -> CryptoHoldingDTO {
        try await client.post(endpoint: "crypto", body: request)
    }

    func sell(id: String, request: SellCryptoRequestDTO) async throws {
        try await client.post(endpoint: "crypto/\(id)/sell", body: request)
    }

    func updatePrices() async throws {
        try await client.post(endpoint: "crypto/update-prices")
    }
}
