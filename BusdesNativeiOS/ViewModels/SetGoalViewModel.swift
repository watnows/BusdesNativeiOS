import SwiftUI
import SwiftData
import Observation

/// 目的地設定画面のViewModel
/// @Observableパターンで状態管理を簡素化
@MainActor
@Observable
final class SetGoalViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    struct State {
        var selectedGoal: String = "南草津駅"
        var showAlert: Bool = false
        var alertMessage: String = ""
        var loadingState = LoadingState()
    }

    var state = State()

    // MARK: - Properties

    let from: BusStop

    // MARK: - Initialization

    init(from: BusStop) {
        self.from = from
    }

    // MARK: - Public Methods

    /// 目的地を選択
    /// - Parameter destination: 目的地名（"南草津駅" or "立命館大学"）
    func selectGoal(_ destination: String) {
        state.selectedGoal = destination
    }

    /// 路線を設定（SwiftData直接操作）
    /// - Parameters:
    ///   - to: 目的地
    ///   - modelContext: SwiftDataのModelContext
    ///   - existingRoutes: 既存の路線リスト（重複チェック用）
    /// - Returns: 設定が成功したかどうか
    @discardableResult
    func setRoute(to: String, modelContext: ModelContext, existingRoutes: [Route]) -> Bool {
        state.loadingState.startLoading()

        // バリデーション: 乗り場と降り場が同じ
        if from.name == to {
            state.alertMessage = "乗り場と降り場が同じようです"
            state.showAlert = true
            state.loadingState.finishLoading()
            return false
        }

        // バリデーション: 既に登録済み
        if existingRoutes.contains(where: { $0.from == from.name && $0.to == to }) {
            state.alertMessage = "既に登録済みのルートです"
            state.showAlert = true
            state.loadingState.finishLoading()
            return false
        }

        // 路線を追加
        let newRoute = Route(to: to, from: from.name)
        modelContext.insert(newRoute)

        do {
            try modelContext.save()
            state.loadingState.finishLoading()
            return true
        } catch {
            state.alertMessage = "路線の追加に失敗しました: \(error.localizedDescription)"
            state.showAlert = true
            state.loadingState.finishLoading()
            return false
        }
    }

    /// アラートを閉じる
    func dismissAlert() {
        state.showAlert = false
        state.alertMessage = ""
    }
}
