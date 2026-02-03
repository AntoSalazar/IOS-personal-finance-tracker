import Foundation

final class AuthAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func signIn(request: SignInRequestDTO) async throws -> AuthResponseDTO {
        try await client.post(endpoint: "auth/sign-in/email", body: request)
    }

    func signUp(request: SignUpRequestDTO) async throws -> AuthResponseDTO {
        try await client.post(endpoint: "auth/sign-up/email", body: request)
    }

    func signOut() async throws {
        try await client.post(endpoint: "auth/sign-out")
    }

    func getSession() async throws -> SessionResponseDTO {
        try await client.request(endpoint: "auth/session")
    }
}
