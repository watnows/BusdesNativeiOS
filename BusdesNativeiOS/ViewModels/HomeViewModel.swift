import Combine
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var timeTables: [UUID: [NextBus]] = [:]
    @Published var countdowns: [UUID: String] = [:]
    @Published var errorMessages: [UUID: NetworkError?] = [:]

    private var apiService: BusAPIServiceProtocol
    private var userModel: UserService
    private let countdownService = CountdownService()
    private var userModelCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?

    init(userModel: UserService, apiService: BusAPIServiceProtocol = BusAPIService()) {
        self.userModel = userModel
        self.apiService = apiService
        Task {
            await fetchAllTimeTables()
        }
        startCountdownTimer()

        userModelCancellable = userModel.$savedRoutes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedRoutes in
                guard let self = self else { return }
                self.clearAllRouteData()
                Task {
                    await self.fetchAllTimeTables()
                }
            }
    }

    deinit {
        timerCancellable?.cancel()
        userModelCancellable?.cancel()
    }

    private func clearAllRouteData() {
        timeTables.removeAll()
        errorMessages.removeAll()
        countdowns.removeAll()
    }

    func parseTime(time: String, requiredTime: Int) -> String {
        return countdownService.parseTime(time: time, requiredTime: requiredTime)
    }

    func fetchTimeTable(for route: Route) async {
        let routeID = route.id

        errorMessages[routeID] = nil

        do {
            let apiResponse = try await apiService.fetchNextBus(from: route.from, to: route.to)

            guard isRouteActive(routeID) else {
                clearRouteData(for: routeID)
                return
            }

            self.timeTables[routeID] = apiResponse.approachInfos
            self.updateCountdown(for: routeID, with: apiResponse.approachInfos)

        } catch let error as NetworkError {
            handleFetchError(error, for: routeID)
        } catch {
            handleFetchError(.networkError(error), for: routeID)
        }
    }

    private func isRouteActive(_ routeID: UUID) -> Bool {
        return userModel.savedRoutes.contains(where: { $0.id == routeID })
    }

    private func clearRouteData(for routeID: UUID) {
        timeTables.removeValue(forKey: routeID)
        errorMessages.removeValue(forKey: routeID)
        countdowns.removeValue(forKey: routeID)
    }

    private func handleFetchError(_ error: NetworkError, for routeID: UUID) {
        guard isRouteActive(routeID) else {
            clearRouteData(for: routeID)
            return
        }

        errorMessages[routeID] = error
        timeTables[routeID] = []
        countdowns[routeID] = "---"
    }

    func fetchAllTimeTables() async {
        await withTaskGroup(of: Void.self) { group in
            for route in userModel.savedRoutes {
                group.addTask {
                    await self.fetchTimeTable(for: route)
                }
            }
        }
    }

    private func startCountdownTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let currentRouteIDs = Set(self.userModel.savedRoutes.map { $0.id })

                for routeID in currentRouteIDs {
                    if let currentInfos = self.timeTables[routeID] {
                        self.updateCountdown(for: routeID, with: currentInfos)
                    } else if self.countdowns[routeID] == nil && self.errorMessages[routeID] == nil {
                        self.countdowns[routeID] = "--:--:--"
                    } else if self.errorMessages[routeID] != nil {
                        self.countdowns[routeID] = "---"
                    }
                }

                let existingCountdownKeys = Set(self.countdowns.keys)
                let deletedKeys = existingCountdownKeys.subtracting(currentRouteIDs)
                for key in deletedKeys {
                    self.clearRouteData(for: key)
                }
            }
    }

    private func updateCountdown(for routeID: UUID, with infos: [NextBus]) {
        countdowns[routeID] = countdownService.calculateCountdown(for: infos)
    }
}
