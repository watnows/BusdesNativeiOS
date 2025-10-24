import Foundation
import SwiftData

@MainActor
final class RouteRepositoryImpl {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods
    
    /// 全ての路線を取得
    func fetchAllRoutes() throws -> [Route] {
        let descriptor = FetchDescriptor<Route>(
            sortBy: [SortDescriptor(\.from), SortDescriptor(\.to)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// 新しい路線を保存
    func saveRoute(from: String, to: String) throws {
        // 重複チェック
        let existingDescriptor = FetchDescriptor<Route>(
            predicate: #Predicate { route in
                route.from == from && route.to == to
            }
        )

        let existing = (try? modelContext.fetch(existingDescriptor)) ?? []
        if !existing.isEmpty {
            // 既に存在する場合は何もしない
            return
        }

        // 新しい路線を作成
        let newRoute = Route(to: to, from: from)
        modelContext.insert(newRoute)

        try modelContext.save()
    }

    /// 路線を削除（物理削除）
    func deleteRoute(_ route: Route) throws {
        modelContext.delete(route)
        try modelContext.save()
    }

    /// 路線が保存済みかチェック
    func isRouteSaved(from: String, to: String) -> Bool {
        let descriptor = FetchDescriptor<Route>(
            predicate: #Predicate { route in
                route.from == from && route.to == to
            }
        )
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        return !existing.isEmpty
    }

    // MARK: - Helper Methods

    /// 全ての路線数を取得（デバッグ用）
    func getTotalRouteCount() -> Int {
        let descriptor = FetchDescriptor<Route>()
        return (try? modelContext.fetch(descriptor).count) ?? 0
    }
}

// MARK: - Error Handling
extension RouteRepositoryImpl {
    enum RepositoryError: Error, LocalizedError {
        case saveFailed(Error)
        case fetchFailed(Error)
        case deleteFailed(Error)
        case routeNotFound

        var errorDescription: String? {
            switch self {
            case .saveFailed(let error):
                return "路線の保存に失敗しました: \(error.localizedDescription)"
            case .fetchFailed(let error):
                return "路線の取得に失敗しました: \(error.localizedDescription)"
            case .deleteFailed(let error):
                return "路線の削除に失敗しました: \(error.localizedDescription)"
            case .routeNotFound:
                return "指定された路線が見つかりません"
            }
        }
    }
}
