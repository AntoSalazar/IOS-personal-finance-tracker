import Foundation

// MARK: - Request DTOs

struct SignInRequestDTO: Encodable {
    let email: String
    let password: String
}

struct SignUpRequestDTO: Encodable {
    let email: String
    let password: String
    let name: String
}

// MARK: - Sign In/Up Response DTO

struct AuthResponseDTO: Decodable {
    let redirect: Bool
    let token: String
    let user: UserDTO
}

// MARK: - Get Session Response DTO

struct SessionResponseDTO: Decodable {
    let session: SessionDTO
    let user: UserDTO
}

// MARK: - User DTO

struct UserDTO: Decodable {
    let id: String
    let email: String
    let name: String
    let emailVerified: Bool
    let image: String?
    let createdAt: Date
    let updatedAt: Date

    func toDomain() -> User {
        User(id: id, email: email, name: name)
    }
}

// MARK: - Session DTO

struct SessionDTO: Decodable {
    let id: String
    let token: String
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date
    let ipAddress: String?
    let userAgent: String?
    let userId: String

    func toDomain() -> Session {
        Session(id: id, expiresAt: expiresAt)
    }
}

// MARK: - Domain Mapping

extension AuthResponseDTO {
    func toDomain() -> AuthSession {
        // Create a session from the token
        // Set expiration to 7 days from now (typical session duration)
        let session = Session(
            id: token,
            expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 7)
        )
        return AuthSession(user: user.toDomain(), session: session)
    }
}

extension SessionResponseDTO {
    func toDomain() -> AuthSession {
        AuthSession(user: user.toDomain(), session: session.toDomain())
    }
}
