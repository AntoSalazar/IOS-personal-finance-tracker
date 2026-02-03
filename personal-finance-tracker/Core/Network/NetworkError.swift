import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case serverError(String)
    case networkUnavailable
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .serverError(let message):
            return message
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

struct APIErrorResponse: Codable {
    let message: String?
    let error: String?

    var errorMessage: String {
        message ?? error ?? "Unknown error"
    }
}
