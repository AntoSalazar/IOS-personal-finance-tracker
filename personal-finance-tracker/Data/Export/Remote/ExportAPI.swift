import Foundation

final class ExportAPI {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func exportData() async throws -> URL {
        let url = AppConfig.baseAPIURL.appendingPathComponent("export")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(AppConfig.apiBaseURL.absoluteString, forHTTPHeaderField: "Origin")
        request.setValue("PersonalFinanceTracker-iOS", forHTTPHeaderField: "X-Client-Platform")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("finance_export_\(Int(Date().timeIntervalSince1970)).json")
        try data.write(to: fileURL)
        return fileURL
    }
}
