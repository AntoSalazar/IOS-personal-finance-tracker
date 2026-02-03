import Foundation

enum AppConfig {
    static let apiBaseURL: URL = {
        #if DEBUG
        guard let url = URL(string: "http://localhost:3000") else {
            fatalError("Invalid API base URL")
        }
        return url
        #else
        guard let url = URL(string: "https://api.yourproductiondomain.com") else {
            fatalError("Invalid API base URL")
        }
        return url
        #endif
    }()

    static let apiVersion = "api"

    static var baseAPIURL: URL {
        apiBaseURL.appendingPathComponent(apiVersion)
    }
}
