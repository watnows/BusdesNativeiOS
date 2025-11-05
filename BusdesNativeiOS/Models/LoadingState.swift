import Foundation

/// ローディング状態を管理する共通ヘルパー
///
/// ## 概要
/// ViewModelのState構造体内で使用し、非同期処理の状態を統一的に管理します。
/// ローディング中・成功・失敗の3状態を明示的に表現し、エラーメッセージの一元管理を実現します。
///
/// ## 主な機能
/// - **状態遷移**: startLoading → finishLoading/failLoading の明確なフロー
/// - **エラー処理**: Error型の自動変換とローカライズ対応
/// - **型安全**: Computed propertiesによる状態チェック
///
/// ## 使用例
/// ```swift
/// @Observable
/// final class MyViewModel {
///     struct State {
///         var loadingState = LoadingState()
///         var data: [Item] = []
///     }
///     var state = State()
///
///     func fetchData() async {
///         state.loadingState.startLoading()
///         do {
///             state.data = try await api.fetchItems()
///             state.loadingState.finishLoading()
///         } catch {
///             state.loadingState.failLoading(with: error)
///         }
///     }
/// }
/// ```
///
/// ## 状態遷移図
/// ```
/// Idle (初期状態)
///   ↓ startLoading()
/// Loading
///   ↓ finishLoading()  or  failLoading()
/// Idle / Error
/// ```
///
/// ## ViewModelパターンとの統合
/// - **State構造体**: ViewModelのStateプロパティ内で使用
/// - **@Observable**: 自動的な画面更新をトリガー
/// - **エラー表示**: errorMessageをSwiftUIのalert/overlayで表示
///
/// ## エラーメッセージ標準化
/// - ネットワークエラー: "ネットワーク接続を確認してください"
/// - デコードエラー: "データの読み込みに失敗しました"
/// - LocalizedError: errorDescriptionを優先的に使用
struct LoadingState {
    // MARK: - Properties

    /// ローディング中フラグ
    ///
    /// ## 用途
    /// - SwiftUIのProgressView表示制御
    /// - ボタンの無効化（二重送信防止）
    var isLoading = false

    /// エラーメッセージ
    ///
    /// ## 値
    /// - `nil`: エラーなし
    /// - `String`: エラー発生時のメッセージ
    ///
    /// ## 表示例
    /// - "ネットワーク接続を確認してください"
    /// - "データの読み込みに失敗しました"
    var errorMessage: String? = nil

    // MARK: - State Transitions

    /// ローディング開始
    ///
    /// ## 処理フロー
    /// 1. isLoadingをtrueに設定
    /// 2. errorMessageをクリア（前回のエラーをリセット）
    ///
    /// ## 使用例
    /// ```swift
    /// state.loadingState.startLoading()
    /// let data = try await fetchData()
    /// state.loadingState.finishLoading()
    /// ```
    ///
    /// ## 注意
    /// - 既にローディング中の場合でも安全に呼び出せます
    /// - エラーメッセージは自動的にクリアされます
    mutating func startLoading() {
        isLoading = true
        errorMessage = nil
    }

    /// ローディング成功
    ///
    /// ## 処理フロー
    /// 1. isLoadingをfalseに設定
    /// 2. errorMessageをクリア
    ///
    /// ## 使用例
    /// ```swift
    /// do {
    ///     let data = try await api.fetch()
    ///     state.loadingState.finishLoading()
    /// } catch {
    ///     state.loadingState.failLoading(with: error)
    /// }
    /// ```
    mutating func finishLoading() {
        isLoading = false
        errorMessage = nil
    }

    /// ローディング失敗（文字列メッセージ）
    ///
    /// ## パラメータ
    /// - message: 表示するエラーメッセージ
    ///
    /// ## 使用例
    /// ```swift
    /// if response.statusCode == 404 {
    ///     state.loadingState.failLoading(with: "データが見つかりません")
    /// }
    /// ```
    ///
    /// ## 注意
    /// - 汎用的なエラー処理には`failLoading(with: Error)`を推奨
    mutating func failLoading(with message: String) {
        isLoading = false
        errorMessage = message
    }

    /// ローディング失敗（Error型から自動変換）
    ///
    /// ## 処理フロー
    /// 1. isLoadingをfalseに設定
    /// 2. ErrorからerrorMessageを抽出
    ///    - LocalizedError: errorDescriptionを優先
    ///    - 通常のError: localizedDescriptionを使用
    ///
    /// ## パラメータ
    /// - error: エラーオブジェクト
    ///
    /// ## 使用例
    /// ```swift
    /// do {
    ///     try await performOperation()
    /// } catch {
    ///     state.loadingState.failLoading(with: error)
    /// }
    /// ```
    ///
    /// ## エラーメッセージ例
    /// - URLError.notConnectedToInternet → "インターネット接続がありません"
    /// - DecodingError → "データの読み込みに失敗しました"
    /// - 独自Error → localizedDescriptionの内容
    mutating func failLoading(with error: Error) {
        isLoading = false
        if let localizedError = error as? LocalizedError {
            errorMessage = localizedError.errorDescription ?? error.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed Properties

    /// エラーが発生しているかどうか
    ///
    /// ## 戻り値
    /// - `true`: errorMessageがnil以外
    /// - `false`: errorMessageがnil
    ///
    /// ## 使用例
    /// ```swift
    /// if state.loadingState.hasError {
    ///     Text(state.loadingState.errorMessage ?? "")
    ///         .foregroundColor(.red)
    /// }
    /// ```
    var hasError: Bool {
        errorMessage != nil
    }

    /// 正常な状態（ローディング中でもエラーでもない）
    ///
    /// ## 戻り値
    /// - `true`: ローディング中でなく、エラーもない
    /// - `false`: ローディング中 または エラーあり
    ///
    /// ## 使用例
    /// ```swift
    /// if state.loadingState.isIdle {
    ///     // 通常のコンテンツ表示
    ///     ContentView(data: state.data)
    /// }
    /// ```
    var isIdle: Bool {
        !isLoading && !hasError
    }
}
