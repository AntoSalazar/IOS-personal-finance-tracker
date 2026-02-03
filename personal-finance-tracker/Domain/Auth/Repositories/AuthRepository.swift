import Foundation

protocol AuthRepository {
    func signIn(credentials: SignInCredentials) async throws -> AuthSession
    func signUp(credentials: SignUpCredentials) async throws -> AuthSession
    func signOut() async throws
    func getSession() async throws -> AuthSession?
}
