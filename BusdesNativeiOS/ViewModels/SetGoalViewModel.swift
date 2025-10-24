import SwiftUI
import SwiftData
import Observation

/// 目的地設定画面のViewModel
///
/// ## 概要
/// 新しいバス路線を追加する際の目的地選択と路線登録を管理します。
/// `@Observable`マクロによる状態管理とSwiftDataとの統合により、
/// シンプルかつ型安全なデータ永続化を実現しています。
///
/// ## 主な機能
/// - 目的地の選択（南草津駅 or 立命館大学）
/// - 路線の登録（重複・無効チェック付き）
/// - バリデーションエラーのアラート表示
/// - ローディング状態の管理
///
/// ## 使用例
/// ```swift
/// let busStop = BusStop(name: "立命館大学", kana: "りつめいかんだいがく")
/// let viewModel = SetGoalViewModel(from: busStop)
///
/// // 目的地を選択
/// viewModel.selectGoal("南草津駅")
///
/// // 路線を登録
/// let success = viewModel.setRoute(
///     to: viewModel.state.selectedGoal,
///     modelContext: modelContext,
///     existingRoutes: routes
/// )
/// ```
///
/// ## SwiftDataとの統合
/// `setRoute(to:modelContext:existingRoutes:)`メソッドでSwiftDataに直接アクセスし、
/// `Route`エンティティの作成・保存を行います。これにより、Repositoryパターンを
/// 介さずにシンプルな実装を実現しています。
@MainActor
@Observable
final class SetGoalViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    ///
    /// ## プロパティ
    /// - `selectedGoal`: 現在選択されている目的地（デフォルト: "南草津駅"）
    /// - `showAlert`: アラート表示フラグ
    /// - `alertMessage`: アラートに表示するメッセージ
    /// - `loadingState`: 路線登録処理中のローディング状態
    struct State {
        var selectedGoal: String = "南草津駅"
        var showAlert: Bool = false
        var alertMessage: String = ""
        var loadingState = LoadingState()
    }

    var state = State()

    // MARK: - Properties

    /// 出発地バス停
    /// 路線登録時に`from`として使用されます
    let from: BusStop

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameter from: 出発地バス停（立命館大学 or 南草津駅）
    init(from: BusStop) {
        self.from = from
    }

    // MARK: - Public Methods

    /// 目的地を選択
    ///
    /// ユーザーがPickerで目的地を変更した際に呼び出されます。
    /// 状態を更新するだけで、バリデーションは行いません。
    ///
    /// - Parameter destination: 目的地名（"南草津駅" or "立命館大学"）
    ///
    /// ## 使用例
    /// ```swift
    /// viewModel.selectGoal("南草津駅")
    /// print(viewModel.state.selectedGoal) // "南草津駅"
    /// ```
    func selectGoal(_ destination: String) {
        state.selectedGoal = destination
    }

    /// 路線を設定（SwiftData直接操作）
    ///
    /// 新しいバス路線をSwiftDataに保存します。
    /// 保存前に以下のバリデーションを実行します：
    /// 1. 出発地と目的地が同じでないか
    /// 2. 同じ路線が既に登録されていないか
    ///
    /// バリデーションエラー時は`state.showAlert`がtrueになり、
    /// エラーメッセージが`state.alertMessage`に設定されます。
    ///
    /// - Parameters:
    ///   - to: 目的地名
    ///   - modelContext: SwiftDataのModelContext（保存先）
    ///   - existingRoutes: 既存の路線リスト（重複チェック用）
    ///
    /// - Returns: 設定が成功したかどうか
    ///   - `true`: 路線が正常に保存された
    ///   - `false`: バリデーションエラーまたは保存失敗
    ///
    /// ## エラーケース
    /// - **出発地と目的地が同じ**: `state.alertMessage = "乗り場と降り場が同じようです"`
    /// - **既に登録済み**: `state.alertMessage = "既に登録済みのルートです"`
    /// - **保存失敗**: `state.alertMessage = "路線の追加に失敗しました: <エラー詳細>"`
    ///
    /// ## 使用例
    /// ```swift
    /// let success = viewModel.setRoute(
    ///     to: "南草津駅",
    ///     modelContext: modelContext,
    ///     existingRoutes: currentRoutes
    /// )
    /// if success {
    ///     // 画面を閉じる、または成功メッセージを表示
    /// }
    /// ```
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
    ///
    /// エラーアラートの表示をリセットします。
    /// アラートのOKボタンが押された際に呼び出されます。
    ///
    /// ## 動作
    /// - `state.showAlert`を`false`に設定
    /// - `state.alertMessage`を空文字列にクリア
    func dismissAlert() {
        state.showAlert = false
        state.alertMessage = ""
    }
}
