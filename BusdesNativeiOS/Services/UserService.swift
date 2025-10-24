import SwiftUI
import Combine
import SwiftData

@MainActor
class UserService: ObservableObject {
    @Published private(set) var savedRoutes: [Route] = []
    private let routeRepositoryImpl: RouteRepositoryImpl
    private var cancellables = Set<AnyCancellable>()

    @Published var lastError: String? = nil

    init(modelContext: ModelContext) {
        self.routeRepositoryImpl = RouteRepositoryImpl(modelContext: modelContext)
        loadRoutes()
    }
    
    func loadRoutes() {
        do {
            self.savedRoutes = try routeRepositoryImpl.fetchAllRoutes()
            self.lastError = nil
        } catch {
            self.lastError = "路線の読み込みに失敗しました: \(error.localizedDescription)"
            self.savedRoutes = []
        }
    }
    
    /// 新しい路線を追加
    func addRoute(from: String, to: String) {
        do {
            try routeRepositoryImpl.saveRoute(from: from, to: to)
            loadRoutes()
            self.lastError = nil
        } catch {
            self.lastError = "路線の追加に失敗しました: \(error.localizedDescription)"
        }
    }

    /// 路線を削除（単一）
    func deleteRoute(_ route: Route) {
        do {
            try routeRepositoryImpl.deleteRoute(route)
            loadRoutes()
            self.lastError = nil
        } catch {
            self.lastError = "路線の削除に失敗しました: \(error.localizedDescription)"
        }
    }

    /// 路線を複数削除（IndexSet指定）
    func deleteRoutes(at offsets: IndexSet) {
        let routesToDelete = offsets.compactMap { index -> Route? in
            guard savedRoutes.indices.contains(index) else { return nil }
            return savedRoutes[index]
        }

        guard !routesToDelete.isEmpty else { return }

        var firstEncounteredError: Error? = nil

        for route in routesToDelete {
            do {
                try routeRepositoryImpl.deleteRoute(route)
            } catch {
                if firstEncounteredError == nil {
                    firstEncounteredError = error
                }
            }
        }

        loadRoutes()

        if let error = firstEncounteredError {
            self.lastError = "路線の削除に失敗しました: \(error.localizedDescription)"
        } else {
            self.lastError = nil
        }
    }
    func isRouteSaved(from: String, to: String) -> Bool {
        return routeRepositoryImpl.isRouteSaved(from: from, to: to)
    }
}
