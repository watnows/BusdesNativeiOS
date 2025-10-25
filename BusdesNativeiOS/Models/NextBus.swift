import Foundation

/// 次のバス情報を表すドメインモデル
///
/// ## 概要
/// APIから取得した次発バス情報を保持します。到着予測時刻、遅延情報、
/// 経由地などの詳細情報を含みます。`Codable`によるJSON自動変換と、
/// `id`プロパティによるList表示の一意性を実現しています。
///
/// ## 主な用途
/// - **ホーム画面**: 次発バスの表示とカウントダウン
/// - **時刻表**: 複数バスの一覧表示
/// - **リアルタイム更新**: 定期的なAPI取得と画面更新
///
/// ## 使用例
/// ```swift
/// // JSON APIからのデコード
/// let buses = try JSONDecoder().decode([NextBus].self, from: jsonData)
///
/// // カウントダウン計算
/// let countdown = countdownService.calculateCountdown(for: buses)
///
/// // 到着時刻計算
/// let arrivalTime = countdownService.parseTime(
///     time: bus.realArrivalTime,
///     requiredTime: bus.requiredTime
/// )
/// ```
///
/// ## データソース
/// - **API**: `https://watnow.dev/...php/busdes_json.php?action=getdata&...`
/// - **更新頻度**: 1秒ごと（HomeViewModelのタイマー）
///
/// ## プロパティ設計
/// - `let`による不変性: データの一貫性を保証
/// - `UUID`自動生成: SwiftUI List表示の一意性確保
/// - `CodingKeys`カスタマイズ: JSONキー名とSwiftプロパティ名のマッピング
///
/// ## 時刻フォーマット
/// - **HH:mm形式**: "10:30", "23:50"など
/// - **深夜バス対応**: 日付跨ぎ処理はCountdownServiceで実装
struct NextBus: Codable {
    /// 一意識別子（SwiftUI List表示用）
    ///
    /// ## 注意
    /// - JSONにはない追加プロパティ（CodingKeysから除外）
    /// - 毎回新しいUUIDが生成される（インスタンス作成時）
    let id: UUID = UUID()

    /// あと何分で来るか（APIから提供される推定値）
    ///
    /// ## 例
    /// - "5"（5分後）
    /// - "12"（12分後）
    /// - "出発"（既に出発済み）
    let moreMin: String

    /// 現在地到着予測時刻（HH:mm形式）
    ///
    /// ## 用途
    /// - カウントダウン計算の基準時刻
    /// - 深夜バス判定（日付跨ぎ処理）
    ///
    /// ## 例
    /// - "10:30"（午前10時30分）
    /// - "23:50"（深夜11時50分）
    let realArrivalTime: String

    /// バスの進行方向
    ///
    /// ## 例
    /// - "立命館大学行き"
    /// - "南草津駅行き"
    let direction: String

    /// 経由地情報
    ///
    /// ## 例
    /// - "イオンモール草津経由"
    /// - "直通"
    let via: String

    /// 予定時刻（HH:mm形式、ダイヤ上の時刻）
    ///
    /// ## 用途
    /// - 遅延計算の基準時刻
    /// - 時刻表表示
    let scheduledTime: String

    /// 遅延時間（分単位、文字列）
    ///
    /// ## 例
    /// - "0"（定刻）
    /// - "5"（5分遅れ）
    /// - "-2"（2分早着）
    let delay: String

    /// 出発バス停名
    ///
    /// ## 例
    /// - "立命館大学"
    /// - "南草津駅"
    let busStop: String

    /// 所要時間（分単位）
    ///
    /// ## 用途
    /// - 目的地到着時刻計算（CountdownService.parseTime）
    /// - ルート所要時間表示
    ///
    /// ## 例
    /// - 15（15分）
    /// - 25（25分）
    let requiredTime: Int

    /// JSON ↔ Swiftのキーマッピング
    ///
    /// ## 注意
    /// - `id`はJSONに含まれない（Swift側で自動生成）
    /// - 他のプロパティはJSONキー名と同一
    enum CodingKeys: String, CodingKey {
        case moreMin
        case realArrivalTime
        case direction
        case via
        case scheduledTime
        case delay
        case busStop
        case requiredTime
    }
}
