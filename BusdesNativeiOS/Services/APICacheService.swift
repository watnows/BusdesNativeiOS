//
//  APICacheService.swift
//  BusdesNativeiOS
//
//  API レスポンスキャッシングサービス
//

import Foundation

/// APIレスポンスのキャッシュエントリ
struct CacheEntry<T> {
    let data: T
    let timestamp: Date
    let expirationInterval: TimeInterval

    /// キャッシュが有効期限内かどうか
    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < expirationInterval
    }
}

/// APIレスポンスをメモリキャッシュするサービス
/// スレッドセーフな実装でパフォーマンスを向上
@MainActor
final class APICacheService {

    // MARK: - Singleton

    static let shared = APICacheService()

    // MARK: - Properties

    /// バス接近情報のキャッシュ（キー: "from-to"）
    private var approachInfoCache: [String: CacheEntry<ApproachInfo>] = [:]

    /// 時刻表のキャッシュ（キー: "from-to"）
    private var timeTableCache: [String: CacheEntry<TimeTable>] = [:]

    /// デフォルトのキャッシュ有効期限
    private let defaultExpirationInterval: TimeInterval = 30 // 30秒

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods - ApproachInfo

    /// バス接近情報をキャッシュから取得
    /// - Parameters:
    ///   - from: 出発地
    ///   - to: 目的地
    /// - Returns: キャッシュされた接近情報（有効期限内の場合）
    func getApproachInfo(from: String, to: String) -> ApproachInfo? {
        let key = cacheKey(from: from, to: to)

        guard let entry = approachInfoCache[key], entry.isValid else {
            // キャッシュが存在しないか、期限切れの場合は削除
            approachInfoCache.removeValue(forKey: key)
            return nil
        }

        return entry.data
    }

    /// バス接近情報をキャッシュに保存
    /// - Parameters:
    ///   - data: 接近情報
    ///   - from: 出発地
    ///   - to: 目的地
    ///   - expirationInterval: キャッシュ有効期限（秒）、デフォルト30秒
    func setApproachInfo(_ data: ApproachInfo, from: String, to: String, expirationInterval: TimeInterval? = nil) {
        let key = cacheKey(from: from, to: to)
        let interval = expirationInterval ?? defaultExpirationInterval

        let entry = CacheEntry(
            data: data,
            timestamp: Date(),
            expirationInterval: interval
        )

        approachInfoCache[key] = entry
    }

    // MARK: - Public Methods - TimeTable

    /// 時刻表をキャッシュから取得
    /// - Parameters:
    ///   - from: 出発地
    ///   - to: 目的地
    /// - Returns: キャッシュされた時刻表（有効期限内の場合）
    func getTimeTable(from: String, to: String) -> TimeTable? {
        let key = cacheKey(from: from, to: to)

        guard let entry = timeTableCache[key], entry.isValid else {
            timeTableCache.removeValue(forKey: key)
            return nil
        }

        return entry.data
    }

    /// 時刻表をキャッシュに保存
    /// - Parameters:
    ///   - data: 時刻表
    ///   - from: 出発地
    ///   - to: 目的地
    ///   - expirationInterval: キャッシュ有効期限（秒）、デフォルト300秒（5分）
    func setTimeTable(_ data: TimeTable, from: String, to: String, expirationInterval: TimeInterval? = nil) {
        let key = cacheKey(from: from, to: to)
        // 時刻表は変更頻度が低いため、デフォルト5分
        let interval = expirationInterval ?? 300

        let entry = CacheEntry(
            data: data,
            timestamp: Date(),
            expirationInterval: interval
        )

        timeTableCache[key] = entry
    }

    // MARK: - Public Methods - Cache Management

    /// すべてのキャッシュをクリア
    func clearAllCache() {
        approachInfoCache.removeAll()
        timeTableCache.removeAll()
    }

    /// 期限切れのキャッシュエントリを削除
    func removeExpiredEntries() {
        // 接近情報キャッシュの期限切れエントリを削除
        approachInfoCache = approachInfoCache.filter { $0.value.isValid }

        // 時刻表キャッシュの期限切れエントリを削除
        timeTableCache = timeTableCache.filter { $0.value.isValid }
    }

    /// 特定路線のキャッシュを削除
    /// - Parameters:
    ///   - from: 出発地
    ///   - to: 目的地
    func clearCache(from: String, to: String) {
        let key = cacheKey(from: from, to: to)
        approachInfoCache.removeValue(forKey: key)
        timeTableCache.removeValue(forKey: key)
    }

    // MARK: - Private Methods

    /// キャッシュキーを生成
    /// - Parameters:
    ///   - from: 出発地
    ///   - to: 目的地
    /// - Returns: キャッシュキー
    private func cacheKey(from: String, to: String) -> String {
        "\(from)-\(to)"
    }
}
