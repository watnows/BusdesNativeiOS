import Foundation
import SwiftData

@Model
final class Route {
    @Attribute(.unique) var id: UUID
    var to: String
    var from: String
    var createdAt: Date

    // お気に入り機能
    var isFavorite: Bool = false
    var favoritedAt: Date? = nil  // お気に入り登録日時（並び替え用）

    init(to: String, from: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.to = to
        self.from = from
        self.createdAt = createdAt
        self.isFavorite = false
        self.favoritedAt = nil
    }
}
