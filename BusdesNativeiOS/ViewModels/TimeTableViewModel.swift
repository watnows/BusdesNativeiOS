import Foundation
import Observation

/// 時刻表画面のViewModel
/// @Observableパターンで状態管理を簡素化
/// BusAPIServiceを使用することでキャッシングの恩恵を受ける
@MainActor
@Observable
final class TimeTableViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    struct State {
        var timeTableFromRits: TimeList?
        var timeTableToRits: TimeList?
        var errorMessage: NetworkError?
        var isLoading: Bool = false
    }

    var state = State()

    // MARK: - Dependencies

    private let apiService: BusAPIServiceProtocol

    // MARK: - Initialization

    init(apiService: BusAPIServiceProtocol = BusAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Public Methods

    /// 立命館大学⇔南草津駅の時刻表データを並行取得
    ///
    /// 両方向の時刻表を同時に取得し、平日ダイヤのみを表示用に設定する
    /// エラー発生時は`state.errorMessage`に詳細を格納
    /// BusAPIServiceを使用するため、キャッシュが有効な場合は高速に動作する
    func fetchTimeTable() async {
        state.isLoading = true
        state.errorMessage = nil

        do {
            async let fromRitsData = apiService.fetchTimeTable(from: "立命館大学", to: "南草津駅")
            async let toRitsData = apiService.fetchTimeTable(from: "南草津駅", to: "立命館大学")

            let results = try await (fromRits: fromRitsData, toRits: toRitsData)

            state.timeTableFromRits = results.fromRits.weekdays
            state.timeTableToRits = results.toRits.weekdays

        } catch let error as NetworkError {
            state.errorMessage = error
        } catch {
            state.errorMessage = .networkError(error)
        }

        state.isLoading = false
    }
}
