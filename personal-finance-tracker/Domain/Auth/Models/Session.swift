import Foundation

struct Session: Equatable {
    let id: String
    let expiresAt: Date

    var isValid: Bool {
        expiresAt > Date()
    }
}

struct AuthSession: Equatable {
    let user: User
    let session: Session
}
