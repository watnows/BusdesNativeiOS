import Foundation
import SwiftData

@Model
final class Route {
    @Attribute(.unique) var id: UUID
    var to: String
    var from: String
    var createdAt: Date

    init(to: String, from: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.to = to
        self.from = from
        self.createdAt = createdAt
    }
}
