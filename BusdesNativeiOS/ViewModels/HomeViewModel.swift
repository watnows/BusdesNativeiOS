import Foundation
import Observation

/// ホーム画面のViewModel
/// リアルタイムバス情報の更新のみを担当（路線管理はSwiftDataに委譲）
@MainActor
@Observable
final class HomeViewModel {

    // MARK: - State

    /// バス時刻表データ（路線ID → バス情報リスト）
    var timeTables: [UUID: [NextBus]] = [:]

    /// カウントダウン文字列（路線ID → カウントダウン表示）
    var countdowns: [UUID: String] = [:]

    /// エラーメッセージ（路線ID → エラー）
    var errorMessages: [UUID: NetworkError?] = [:]

    // MARK: - Dependencies

    private var apiService: BusAPIServiceProtocol
    private let countdownService = CountdownService()
    private let timerService = TimerService()

    // MARK: - Initialization

    init(apiService: BusAPIServiceProtocol = BusAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Public Methods

    /// リアルタイム更新を開始
    /// - Parameter routes: 監視対象の路線リスト
    func startRealtimeUpdates(for routes: [Route]) async {
        // 初回のバス情報取得
        await fetchAllTimeTables(for: routes)

        // カウントダウンタイマー開始（1秒ごと）
        timerService.startRepeatingTimer(interval: 1.0) { [weak self] in
            guard let self = self else { return }
            await self.updateCountdowns(for: routes)
        }
    }

    /// 路線リストが更新された時の処理
    /// - Parameter routes: 新しい路線リスト
    func updateRoutes(_ routes: [Route]) async {
        // 不要なデータを削除
        let routeIds = Set(routes.map { $0.id })
        timeTables = timeTables.filter { routeIds.contains($0.key) }
        errorMessages = errorMessages.filter { routeIds.contains($0.key) }
        countdowns = countdowns.filter { routeIds.contains($0.key) }

        // 新しい路線のバス情報を取得
        await fetchAllTimeTables(for: routes)
    }

    /// バス時刻を解析して到着時刻を返す
    /// - Parameters:
    ///   - time: バス時刻（HH:mm形式）
    ///   - requiredTime: 所要時間（分）
    /// - Returns: 到着時刻文字列
    func parseTime(time: String, requiredTime: Int) -> String {
        return countdownService.parseTime(time: time, requiredTime: requiredTime)
    }

    // MARK: - Private Methods

    /// 全路線のバス時刻表を取得
    /// - Parameter routes: 取得対象の路線リスト
    func fetchAllTimeTables(for routes: [Route]) async {
        await withTaskGroup(of: Void.self) { group in
            for route in routes {
                group.addTask {
                    await self.fetchTimeTable(for: route)
                }
            }
        }
    }

    /// 単一路線のバス時刻表を取得
    /// - Parameter route: 取得対象の路線
    private func fetchTimeTable(for route: Route) async {
        let routeID = route.id

        errorMessages[routeID] = nil

        do {
            let apiResponse = try await apiService.fetchNextBus(from: route.from, to: route.to)
            self.timeTables[routeID] = apiResponse.approachInfos
            self.updateCountdown(for: routeID, with: apiResponse.approachInfos)

        } catch let error as NetworkError {
            handleFetchError(error, for: routeID)
        } catch {
            handleFetchError(.networkError(error), for: routeID)
        }
    }

    /// エラー処理
    /// - Parameters:
    ///   - error: ネットワークエラー
    ///   - routeID: 路線ID
    private func handleFetchError(_ error: NetworkError, for routeID: UUID) {
        errorMessages[routeID] = error
        timeTables[routeID] = []
        countdowns[routeID] = "---"
    }

    /// カウントダウンを更新
    /// - Parameter routes: 監視対象の路線リスト
    private func updateCountdowns(for routes: [Route]) async {
        let currentRouteIDs = Set(routes.map { $0.id })

        for routeID in currentRouteIDs {
            if let currentInfos = self.timeTables[routeID] {
                self.updateCountdown(for: routeID, with: currentInfos)
            } else if self.countdowns[routeID] == nil && self.errorMessages[routeID] == nil {
                self.countdowns[routeID] = "--:--:--"
            } else if self.errorMessages[routeID] != nil {
                self.countdowns[routeID] = "---"
            }
        }
    }

    /// 単一路線のカウントダウンを更新
    /// - Parameters:
    ///   - routeID: 路線ID
    ///   - infos: バス情報リスト
    private func updateCountdown(for routeID: UUID, with infos: [NextBus]) {
        countdowns[routeID] = countdownService.calculateCountdown(for: infos)
    }
}
