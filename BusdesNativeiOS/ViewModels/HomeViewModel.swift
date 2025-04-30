import Combine
import Foundation
import CoreData

@MainActor
class HomeViewModel: ObservableObject {
    @Published var timeTables: [NSManagedObjectID: [NextBusModel]] = [:]
    @Published var countdowns: [NSManagedObjectID: String] = [:]
    @Published var errorMessages: [NSManagedObjectID: NetworkError?] = [:]
    
    private var apiService: BusAPIServiceProtocol
    private var userModel: UserSession
    private var userModelCancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    init(userModel: UserSession, apiService: BusAPIServiceProtocol = BusAPIService()) {
        self.userModel = userModel
        self.apiService = apiService
        // 初期データ取得は非同期に行う
        Task {
            await fetchAllTimeTables()
        }
        startCountdownTimer()
        
        // UserModelの監視 (sink内も @MainActor の影響下にある)
        userModelCancellable = userModel.$savedRoutes
            .sink { [weak self] updatedRoutes in
                guard let self = self else { return }
                self.clearAllRouteData()
                // 路線更新時も非同期で実行
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
        if let date = dateFormatter.date(from: time),
           let newDate = Calendar.current.date(byAdding: .minute, value: requiredTime, to: date) {
            return dateFormatter.string(from: newDate) + "着"
        }
        return "--:--"
    }
    
    func fetchTimeTable(for route: Routes) async {
        let routeID = route.objectID
        guard let from = route.from, let to = route.to else {
            self.errorMessages[routeID] = .invalidURL // カスタムエラーを設定
            self.timeTables[routeID] = []
            self.countdowns[routeID] = "---"
            return
        }
        
        errorMessages[routeID] = nil
        
        do {
            let apiResponse = try await apiService.fetchNextBus(from: from, to: to)
            
            guard userModel.savedRoutes.contains(where: { $0.objectID == routeID }) else {
                // logger.info("Route with ID \(routeID) was deleted before API response processed. Discarding result.") // OSLog使用例
                // ルートが削除されていた場合、状態をクリア
                timeTables.removeValue(forKey: routeID)
                errorMessages.removeValue(forKey: routeID)
                countdowns.removeValue(forKey: routeID)
                return
            }
            
            self.timeTables[routeID] = apiResponse.approachInfos
            self.updateCountdown(for: route, with: apiResponse.approachInfos)
            
        } catch let error as NetworkError {
            self.errorMessages[routeID] = error
            self.timeTables[routeID] = []
            self.countdowns[routeID] = "---"
        } catch {
            self.errorMessages[routeID] = .networkError(error)
            self.timeTables[routeID] = []
            self.countdowns[routeID] = "---"
        }
    }
    
    
    // fetchAllTimeTablesをasyncに変更
    func fetchAllTimeTables() async {
        // 非同期タスクグループを使って並列処理も可能だが、まずは逐次実行
        for route in userModel.savedRoutes {
            // Contextが削除されていないかチェックしてから実行
            // (ループ中に削除される可能性は低いが念のため)
            if !route.isDeleted {
                await fetchTimeTable(for: route)
            }
        }
        
        // --- 非同期タスクグループを使った並列実行の例 (参考) ---
        // await withTaskGroup(of: Void.self) { group in
        //     for route in userModel.savedRoutes {
        //         if !route.isDeleted {
        //             group.addTask {
        //                 await self.fetchTimeTable(for: route)
        //             }
        //         }
        //     }
        // }
    }
    
    // API通信メソッドを async throws に変更
    private func fetchNextBusAPI(fr: String, to: String) async throws -> ApproachInfo {
        // 1. URL生成とエンコーディング
        guard let url = Constants.API.nextBusURL(from: fr, to: to) else {
            throw NetworkError.invalidURL // または .encodingError
        }
        
        // 2. URLSessionでデータ取得 (async/await版)
        let data: Data
        let response: URLResponse
        do {
            // data(from:delegate:) を使用
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            // 通信エラーをラップしてthrow
            throw NetworkError.networkError(error)
        }
        
        // 3. HTTPステータスコード検証
        guard let httpResponse = response as? HTTPURLResponse else {
            // HTTPレスポンスでない場合はエラー (通常は発生しにくい)
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            // ステータスコードが200番台以外ならエラー
            throw NetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
        
        // 4. データのデコード
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(ApproachInfo.self, from: data)
            return apiResponse
        } catch {
            // デコードエラーをラップしてthrow
            throw NetworkError.decodingError(error)
        }
        // dataが空の場合のチェックは、通常デコードエラーに含まれることが多いが、
        // 明示的にチェックしたい場合はデコード前に行う
        // guard !data.isEmpty else { throw NetworkError.noData }
    }
    
    private func startCountdownTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.userModel.savedRoutes.forEach { route in
                    let routeID = route.objectID
                    if let currentInfos = self.timeTables[routeID] {
                        self.updateCountdown(for: route, with: currentInfos)
                    }
                    else if self.countdowns[routeID] == nil {
                        self.countdowns[routeID] = "--:--:--"
                    }
                }
            }
    }
    
    private func updateCountdown(for route: Routes, with infos: [NextBusModel]) {
        let routeID = route.objectID
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        var nextBusTime: Date?
        
        for info in infos {
            guard let time = formatter.date(from: info.realArrivalTime) else { continue }
            
            var targetComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
            let nowComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
            targetComponents.year = nowComponents.year
            targetComponents.month = nowComponents.month
            targetComponents.day = nowComponents.day
            guard let targetDateTime = Calendar.current.date(from: targetComponents) else { continue }
            
            if targetDateTime > now {
                if let currentNext = nextBusTime {
                    if targetDateTime < currentNext { nextBusTime = targetDateTime }
                } else {
                    nextBusTime = targetDateTime
                }
            }
        }
        
        if let targetTime = nextBusTime {
            let diff = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: targetTime)
            if let hour = diff.hour, let minute = diff.minute, let second = diff.second,
               hour >= 0, minute >= 0, second >= 0 {
                self.countdowns[routeID] = String(format: "%02d:%02d:%02d", hour, minute, second)
            } else {
                self.countdowns[routeID] = "出発"
            }
        } else {
            self.countdowns[routeID] = "終了"
        }
    }
}
