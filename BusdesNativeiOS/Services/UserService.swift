import SwiftUI
import Combine
import CoreData

@MainActor
class UserSession: ObservableObject {
    @Published private(set) var savedRoutes: [Routes] = []
    private let routeRepository: RouteRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var lastError: RouteRepositoryError? = nil

    init(routeRepository: RouteRepositoryProtocol = CoreDataRouteRepository()) {
        self.routeRepository = routeRepository
        loadRoutes()
    }

    func loadRoutes() {
        do {
            self.savedRoutes = try routeRepository.fetchSavedRoutes()
            self.lastError = nil
        } catch let error as RouteRepositoryError {
            self.lastError = error
            self.savedRoutes = []
        } catch {
            self.lastError = .fetchFailed(error)
            self.savedRoutes = []
        }
    }

    func addRoute(from: String, to: String) {
        Task {
            do {
                try await routeRepository.addRoute(from: from, to: to)
                loadRoutes()
                self.lastError = nil
            } catch let error as RouteRepositoryError {
                self.lastError = error
            } catch {
                self.lastError = .saveFailed(error)
            }
        }
    }

    func deleteRoute(_ route: Routes) {
        if let index = savedRoutes.firstIndex(where: { $0.objectID == route.objectID }) {
            savedRoutes.remove(at: index)
        }

        Task {
            do {
                try await routeRepository.deleteRoute(route)
                self.lastError = nil
            } catch let error as RouteRepositoryError {
                loadRoutes()
                self.lastError = error
            } catch {
                loadRoutes()
                self.lastError = .deleteFailed(error)
            }
        }
    }

    func deleteRoute(by objectID: NSManagedObjectID) {
        if let index = savedRoutes.firstIndex(where: { $0.objectID == objectID }) {
            savedRoutes.remove(at: index)
        }

        Task {
            do {
                try await routeRepository.deleteRoute(by: objectID)
                self.lastError = nil
            } catch let error as RouteRepositoryError {
                loadRoutes()
                self.lastError = error
            } catch {
                loadRoutes()
                self.lastError = .deleteFailed(error)
            }
        }
    }
    
    func deleteRoutes(at offsets: IndexSet) {
        let routesToDelete = offsets.map { savedRoutes[$0] }
        savedRoutes.remove(atOffsets: offsets)
        Task {
            var encounteredError: RouteRepositoryError? = nil
            for route in routesToDelete {
                do {
                    try await routeRepository.deleteRoute(by: route.objectID)
                } catch let error as RouteRepositoryError {
                    encounteredError = error
                } catch {
                     encounteredError = .deleteFailed(error)
                }
            }
            if let error = encounteredError {
                self.lastError = error
                loadRoutes()
            } else {
                self.lastError = nil
            }
        }
    }
}
