import Foundation

enum SubscriptionStatus: String, Codable, CaseIterable, Identifiable {
    case active = "ACTIVE"
    case paused = "PAUSED"
    case cancelled = "CANCELLED"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        }
    }
}
