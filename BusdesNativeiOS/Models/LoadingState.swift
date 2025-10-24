import Foundation

/// ローディング状態を管理する共通ヘルパー
/// ViewModelのState構造体内で使用し、非同期処理の状態を統一的に管理
struct LoadingState {
    var isLoading = false
    var errorMessage: String? = nil

    // MARK: - State Transitions

    /// ローディング開始
    /// - Note: エラーメッセージをクリアして、ローディング状態に遷移
    mutating func startLoading() {
        isLoading = true
        errorMessage = nil
    }

    /// ローディング成功
    /// - Note: ローディング状態を終了し、エラーメッセージをクリア
    mutating func finishLoading() {
        isLoading = false
        errorMessage = nil
    }

    /// ローディング失敗
    /// - Parameter message: エラーメッセージ
    mutating func failLoading(with message: String) {
        isLoading = false
        errorMessage = message
    }

    /// ローディング失敗（Error型から）
    /// - Parameter error: エラーオブジェクト
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
    var hasError: Bool {
        errorMessage != nil
    }

    /// 正常な状態（ローディング中でもエラーでもない）
    var isIdle: Bool {
        !isLoading && !hasError
    }
}
