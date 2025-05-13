import SwiftUI
import Combine
import CoreData

@MainActor
class UserService: ObservableObject {
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
            let fetchedRoutes = try routeRepository.fetchSavedRoutes()
            self.savedRoutes = fetchedRoutes.filter{ !$0.isDeleted && $0.managedObjectContext != nil }
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
                loadRoutes()
            } catch {
                self.lastError = .saveFailed(error)
                loadRoutes()
            }
        }
    }
    
    func deleteRoute(_ route: Routes) {
        Task {
            do {
                try await routeRepository.deleteRoute(route)
                loadRoutes()
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
        let routesToDelete = offsets.compactMap { index -> Routes? in
            guard savedRoutes.indices.contains(index) else { return nil }
            let route = savedRoutes[index]
            guard !route.isDeleted, route.managedObjectContext != nil else { return nil }
            return route
        }
        
        guard !routesToDelete.isEmpty else { return }
        
        Task {
            var firstEncounteredError: Error? = nil
            
            for route in routesToDelete {
                do {
                    try await routeRepository.deleteRoute(route)
                } catch {
                    if firstEncounteredError == nil {
                        firstEncounteredError = error
                    }
                }
            }
            
            loadRoutes()

            if let error = firstEncounteredError {
                if let routeError = error as? RouteRepositoryError {
                    self.lastError = routeError
                } else {
                    self.lastError = .deleteFailed(error)
                }
            } else {
                self.lastError = nil
            }
        }
    }
    func isRouteSaved(from: String, to: String) -> Bool {
        return savedRoutes.contains { $0.from == from && $0.to == to }
    }
}
