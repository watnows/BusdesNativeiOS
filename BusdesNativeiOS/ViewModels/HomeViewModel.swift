import Combine
import Foundation
import CoreData

@MainActor
class HomeViewModel: ObservableObject {
    @Published var timeTables: [NSManagedObjectID: [NextBusModel]] = [:]
    @Published var countdowns: [NSManagedObjectID: String] = [:]
    @Published var errorMessages: [NSManagedObjectID: NetworkError?] = [:]

    private var apiService: BusAPIServiceProtocol
    private var userModel: UserService
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let date = dateFormatter.date(from: time),
              let arrivalDate = Calendar.current.date(byAdding: .minute, value: requiredTime, to: date) else {
            return "--:--着"
        }
        return dateFormatter.string(from: arrivalDate) + "着"
    }

    func fetchTimeTable(for route: Routes) async {
        let routeID = route.objectID

        guard !route.isDeleted, route.managedObjectContext != nil,
              let from = route.from, let to = route.to else {
            self.errorMessages[routeID] = .invalidURL
            self.timeTables[routeID] = []
            self.countdowns[routeID] = "---"
            return
        }

        errorMessages[routeID] = nil

        do {
            let apiResponse = try await apiService.fetchNextBus(from: from, to: to)

             guard userModel.savedRoutes.contains(where: { $0.objectID == routeID }) else {
                 timeTables.removeValue(forKey: routeID)
                 errorMessages.removeValue(forKey: routeID)
                 countdowns.removeValue(forKey: routeID)
                 return
             }

            self.timeTables[routeID] = apiResponse.approachInfos
            self.updateCountdown(for: routeID, with: apiResponse.approachInfos)

        } catch let error as NetworkError {
            if userModel.savedRoutes.contains(where: { $0.objectID == routeID }) {
                 self.errorMessages[routeID] = error
                 self.timeTables[routeID] = []
                 self.countdowns[routeID] = "---"
             } else {
                 timeTables.removeValue(forKey: routeID)
                 errorMessages.removeValue(forKey: routeID)
                 countdowns.removeValue(forKey: routeID)
             }
        } catch {
            if userModel.savedRoutes.contains(where: { $0.objectID == routeID }) {
                 self.errorMessages[routeID] = .networkError(error)
                 self.timeTables[routeID] = []
                 self.countdowns[routeID] = "---"
             } else {
                  timeTables.removeValue(forKey: routeID)
                 errorMessages.removeValue(forKey: routeID)
                 countdowns.removeValue(forKey: routeID)
             }
        }
    }

    func fetchAllTimeTables() async {
        await withTaskGroup(of: Void.self) { group in
            for route in userModel.savedRoutes {
                 if !route.isDeleted && route.managedObjectContext != nil {
                    group.addTask {
                        await self.fetchTimeTable(for: route)
                    }
                 }
            }
        }
    }

    private func startCountdownTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let currentRouteIDs = Set(self.userModel.savedRoutes.map { $0.objectID })

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
                    self.countdowns.removeValue(forKey: key)
                    self.timeTables.removeValue(forKey: key)
                    self.errorMessages.removeValue(forKey: key)
                }
            }
    }

    private func updateCountdown(for routeID: NSManagedObjectID, with infos: [NextBusModel]) {
        let now = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        var nextBusTime: Date?

        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)

        for info in infos {
            guard let time = formatter.date(from: info.realArrivalTime) else { continue }

            var targetComponents = calendar.dateComponents([.hour, .minute], from: time)
            targetComponents.year = nowComponents.year
            targetComponents.month = nowComponents.month
            targetComponents.day = nowComponents.day

            guard var targetDateTime = calendar.date(from: targetComponents) else { continue }

             if targetDateTime < now && calendar.dateComponents([.hour], from: now, to: targetDateTime).hour ?? 0 < -12 {
                 if let nextDayTarget = calendar.date(byAdding: .day, value: 1, to: targetDateTime) {
                     targetDateTime = nextDayTarget
                 }
             }

            if targetDateTime > now {
                if let currentNext = nextBusTime {
                    if targetDateTime < currentNext {
                        nextBusTime = targetDateTime
                    }
                } else {
                    nextBusTime = targetDateTime
                }
            }
        }

        if let targetTime = nextBusTime {
            let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: targetTime)

            if let hour = diff.hour, let minute = diff.minute, let second = diff.second,
               hour >= 0, minute >= 0, second >= 0 {
                 if hour == 0 && minute == 0 && second < 5 {
                     self.countdowns[routeID] = "出発"
                 } else {
                    self.countdowns[routeID] = String(format: "%02d:%02d:%02d", hour, minute, second)
                 }
            } else {
                 self.countdowns[routeID] = "出発"
            }
        } else {
            self.countdowns[routeID] = "終了"
        }
    }
}
