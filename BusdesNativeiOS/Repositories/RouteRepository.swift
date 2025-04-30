import Foundation
import CoreData

enum RouteRepositoryError: Error, LocalizedError {
    case contextUnavailable
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case routeNotFound

    var errorDescription: String? {
        switch self {
        case .contextUnavailable:
            return "データベースコンテキストにアクセスできませんでした。"
        case .fetchFailed(let error):
            return "路線の読み込みに失敗しました: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "路線の保存に失敗しました: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "路線の削除に失敗しました: \(error.localizedDescription)"
        case .routeNotFound:
            return "指定された路線が見つかりませんでした。"
        }
    }
}


protocol RouteRepositoryProtocol {
    @MainActor func fetchSavedRoutes() throws -> [Routes]
    func addRoute(from: String, to: String) async throws
    func deleteRoute(_ route: Routes) async throws
    func deleteRoute(by objectID: NSManagedObjectID) async throws
}

class CoreDataRouteRepository: RouteRepositoryProtocol {
    private let persistentContainer: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(persistentContainer: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = persistentContainer
        self.viewContext = persistentContainer.viewContext
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.automaticallyMergesChangesFromParent = true
        self.viewContext.automaticallyMergesChangesFromParent = true
    }

    @MainActor
    func fetchSavedRoutes() throws -> [Routes] {
        let request = NSFetchRequest<Routes>(entityName: "Routes")
        do {
            return try viewContext.fetch(request)
        } catch {
            throw RouteRepositoryError.fetchFailed(error)
        }
    }

    func addRoute(from: String, to: String) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self = self else { throw RouteRepositoryError.contextUnavailable }

            let fetchRequest = NSFetchRequest<Routes>(entityName: "Routes")
            fetchRequest.predicate = NSPredicate(format: "from == %@ AND to == %@", from, to)
            fetchRequest.fetchLimit = 1

            let existing = try self.backgroundContext.fetch(fetchRequest)
            guard existing.isEmpty else {
                return
            }

            let newRoute = Routes(context: self.backgroundContext)
            newRoute.from = from
            newRoute.to = to
            try self.saveBackgroundContext()
        }
    }

    func deleteRoute(_ route: Routes) async throws {
        try await backgroundContext.perform { [weak self] in
             guard let self = self else { throw RouteRepositoryError.contextUnavailable }
             guard let backgroundRoute = self.backgroundContext.object(with: route.objectID) as? Routes else {
                 throw RouteRepositoryError.routeNotFound
             }
             self.backgroundContext.delete(backgroundRoute)
             try self.saveBackgroundContext()
        }
    }

    func deleteRoute(by objectID: NSManagedObjectID) async throws {
        try await backgroundContext.perform { [weak self] in
             guard let self = self else { throw RouteRepositoryError.contextUnavailable }
             guard let routeToDelete = self.backgroundContext.object(with: objectID) as? Routes else {
                 return
             }
             self.backgroundContext.delete(routeToDelete)
             try self.saveBackgroundContext()
        }
    }
    private func saveBackgroundContext() throws {
        guard backgroundContext.hasChanges else { return }
        do {
            try backgroundContext.save()
        } catch {
            backgroundContext.rollback()
            throw RouteRepositoryError.saveFailed(error)
        }
    }
}
