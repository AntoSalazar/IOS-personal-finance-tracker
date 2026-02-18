import Foundation

struct Category: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let color: String?
    let icon: String?
    let type: CategoryType
    let parentId: String?
}
