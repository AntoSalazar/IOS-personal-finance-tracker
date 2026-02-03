import Foundation
import os

enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.personal-finance-tracker"

    private static let networkLogger = os.Logger(subsystem: subsystem, category: "Network")
    private static let authLogger = os.Logger(subsystem: subsystem, category: "Auth")
    private static let generalLogger = os.Logger(subsystem: subsystem, category: "General")

    enum Category {
        case network
        case auth
        case general

        var logger: os.Logger {
            switch self {
            case .network: return networkLogger
            case .auth: return authLogger
            case .general: return generalLogger
            }
        }
    }

    static func debug(_ message: String, category: Category = .general) {
        #if DEBUG
        category.logger.debug("\(message)")
        #endif
    }

    static func info(_ message: String, category: Category = .general) {
        category.logger.info("\(message)")
    }

    static func warning(_ message: String, category: Category = .general) {
        category.logger.warning("\(message)")
    }

    static func error(_ message: String, category: Category = .general) {
        category.logger.error("\(message)")
    }
}
