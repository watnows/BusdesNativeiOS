import Foundation

/// 統一的なタイマー管理サービス
/// メモリリークを防止し、ViewModelでの一貫したタイマー制御を提供
@MainActor
final class TimerService {
    private var timer: Timer?
    private var updateAction: (() async -> Void)?

    // MARK: - Timer Control

    /// 定期実行タイマーを開始
    /// - Parameters:
    ///   - interval: 実行間隔（秒）
    ///   - action: 実行するアクション（async対応）
    /// - Note: 既存のタイマーがある場合は自動的に停止してから新しいタイマーを開始
    func startRepeatingTimer(interval: TimeInterval, action: @escaping () async -> Void) {
        stopTimer() // 既存タイマーを停止
        updateAction = action

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                await action()
            }
        }
    }

    /// タイマーを停止
    /// - Note: メモリリーク防止のため、アクションもクリア
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        updateAction = nil
    }

    /// タイマーが動作中かどうか
    var isRunning: Bool {
        timer != nil
    }

    // MARK: - Lifecycle

    deinit {
        // deinitは非同期コンテキストで実行されるため、
        // メインアクター分離されたメソッドを直接呼べない
        // 代わりに、タイマーを直接invalidateする
        timer?.invalidate()
        timer = nil
        updateAction = nil
    }
}
