import Foundation
import SwiftData

@Model
final class Route {
    @Attribute(.unique) var id: UUID
    var to: String
    var from: String

    init(to: String, from: String) {
        self.id = UUID()
        self.to = to
        self.from = from
    }
}
