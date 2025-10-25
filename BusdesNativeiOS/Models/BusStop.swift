import Foundation

/// バス停情報を表すドメインモデル
///
/// ## 概要
/// バス停の名称とかな表記を保持するシンプルな値オブジェクトです。
/// `Codable`により、JSONからのデコード・エンコードが可能で、
/// `Hashable`により、Setやディクショナリのキーとして使用できます。
///
/// ## 主な用途
/// - **路線選択**: AddLineViewModelでのバス停検索・選択
/// - **データ永続化**: SwiftDataでのRoute保存時の参照
/// - **API通信**: busdes_json.phpからのバス停マスタデータ取得
///
/// ## 使用例
/// ```swift
/// // JSON APIからのデコード
/// let busStop = try JSONDecoder().decode(BusStop.self, from: jsonData)
///
/// // フィルタリング（かな検索）
/// let filtered = busStops.filter { $0.kana.contains("りつめい") }
///
/// // Set操作（重複除去）
/// let uniqueBusStops = Set(busStops)
/// ```
///
/// ## データソース
/// - **API**: `https://watnow.dev/...php/busdes_json.php?action=getstations`
/// - **キャッシュ**: BusStopRepositoryでローカル保存
///
/// ## プロパティ設計
/// - `let`による不変性: データの一貫性を保証
/// - `Hashable`: 効率的な検索・比較を実現
/// - `Codable`: JSON ↔ Swift構造体の自動変換
struct BusStop: Codable, Hashable {
    /// バス停名（漢字表記）
    ///
    /// ## 例
    /// - "立命館大学"
    /// - "南草津駅"
    /// - "びわこ・くさつキャンパス"
    let name: String

    /// バス停名（ひらがな表記）
    ///
    /// ## 用途
    /// - 検索フィルタリング（インクリメンタルサーチ）
    /// - 読み仮名表示（アクセシビリティ向上）
    ///
    /// ## 例
    /// - "りつめいかんだいがく"
    /// - "みなみくさつえき"
    /// - "びわこくさつきゃんぱす"
    let kana: String
}

