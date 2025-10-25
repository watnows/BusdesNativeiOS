import Foundation

/// カウントダウン計算とバス到着時刻処理を担当するサービス
///
/// ## 概要
/// バス到着までのリアルタイムカウントダウンと到着時刻計算を提供するサービスです。
/// 深夜0時を跨ぐバスや複数バス間の選択など、複雑な時刻計算をシンプルなAPIで実現しています。
///
/// ## 主な機能
/// - **リアルタイムカウントダウン**: 次のバス到着までの残り時間を秒単位で計算
/// - **日付跨ぎ処理**: 深夜0時前後のバスに対応（23:50 → 00:10など）
/// - **複数バス対応**: ユーザー選択バスまたは最速バスのカウントダウン
/// - **到着時刻計算**: 出発時刻 + 必要時間 → 到着時刻の変換
///
/// ## 使用例
/// ```swift
/// let service = CountdownService()
///
/// // 最も早いバスのカウントダウン
/// let countdown = service.calculateCountdown(for: busInfos)
/// // → "00:15:30" (15分30秒後)
///
/// // ユーザー選択バスのカウントダウン
/// let countdown = service.calculateCountdown(for: busInfos, selectedIndex: 2)
/// // → "00:25:00" (25分後)
///
/// // 到着時刻計算
/// let arrival = service.parseTime(time: "10:30", requiredTime: 15)
/// // → "10:45"
/// ```
///
/// ## 重要な設計判断
/// - **日本標準時（JST）固定**: Asia/Tokyoタイムゾーンで全計算を実行
/// - **出発閾値**: 5秒未満の場合は"出発"表示（誤差対策）
/// - **日付跨ぎ判定**: -12時間を閾値とし、深夜バスを翌日扱い
/// - **Stateless設計**: 状態を持たず、全メソッドが純粋関数として動作
///
/// ## 特殊ケースの処理
/// - **バスなし**: 空配列 → "終了"
/// - **既に出発**: 過去時刻 → "出発"
/// - **パース失敗**: 不正な時刻 → "--:--" or "---"
/// - **深夜0時跨ぎ**: 自動的に翌日として計算
struct CountdownService {
    // MARK: - Constants

    /// サービス定数
    ///
    /// ## 各定数の役割
    /// - `timeZone`: 日本標準時（JST）。全時刻計算の基準
    /// - `dateFormat`: 時刻フォーマット（24時間制）
    /// - `midnightCrossoverThreshold`: 日付跨ぎ判定の閾値（-12時間）
    /// - `departureDisplayThreshold`: "出発"表示の閾値（5秒未満）
    private enum Constants {
        /// 日本標準時（Asia/Tokyo）
        /// バス運行は日本国内のため、タイムゾーンを固定
        static let timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current

        /// 時刻フォーマット（HH:mm）
        /// 24時間制で時と分のみ表示
        static let dateFormat = "HH:mm"

        /// 日付跨ぎ判定の閾値（-12時間）
        ///
        /// ## 判定ロジック
        /// バス時刻が現在時刻より過去で、かつ差が-12時間未満の場合、
        /// そのバスは「翌日の同時刻」と判定します。
        ///
        /// ## 例
        /// - 現在: 23:50, バス: 00:10 → 差: -23時間40分 → 翌日扱い（正）
        /// - 現在: 12:00, バス: 11:00 → 差: -1時間 → 過去扱い（誤り）
        static let midnightCrossoverThreshold = -12

        /// "出発"表示の秒数閾値（5秒未満）
        ///
        /// ## 設計意図
        /// カウントダウンが5秒未満になった時点で"出発"と表示することで、
        /// タイマー更新のタイムラグを考慮し、ユーザーに正確な情報を提供します。
        static let departureDisplayThreshold = 5
    }

    // MARK: - Cached DateFormatter

    /// キャッシュされたDateFormatter（パフォーマンス最適化）
    ///
    /// DateFormatterの生成コストは高いため、staticプロパティとしてキャッシュ化。
    /// スレッドセーフ（structは値型のためコピーされる）。
    private static let cachedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Constants.timeZone
        return formatter
    }()

    // MARK: - Public Methods

    /// 次のバス到着までのカウントダウン文字列を計算
    ///
    /// ## 概要
    /// バス接近情報から次のバスまでの残り時間を計算し、
    /// フォーマットされた文字列として返します。
    /// ユーザーが特定のバスを選択している場合はそのバスを、
    /// 未選択の場合は最も早く到着するバスを自動選択します。
    ///
    /// ## パラメータ
    /// - Parameter infos: バス接近情報の配列（複数バスの時刻を含む）
    /// - Parameter selectedIndex: ユーザーが選択したバスのインデックス
    ///   - `nil`: 最も早いバスを自動選択（デフォルト動作）
    ///   - `0...n`: 指定されたインデックスのバスを選択
    ///
    /// ## 戻り値
    /// 以下のいずれかの文字列を返します：
    /// - **"HH:MM:SS"**: 残り時間（例: "00:15:30" = 15分30秒）
    /// - **"出発"**: バスまで5秒未満、または既に出発済み
    /// - **"終了"**: 該当するバスなし、または全バス出発済み
    ///
    /// ## 計算ロジック
    /// 1. `selectedIndex`が指定されている → そのバスの時刻を使用
    /// 2. `selectedIndex`がnil → 全バスから最速を自動選択
    /// 3. 選択されたバス時刻と現在時刻の差分を計算
    /// 4. 差分が負（過去）または5秒未満 → "出発"
    /// 5. 差分が正（未来） → "HH:MM:SS"形式で表示
    /// 6. バスが存在しない → "終了"
    ///
    /// ## エッジケース
    /// - **空配列**: `infos`が空 → "終了"
    /// - **無効なインデックス**: 範囲外 → "終了"
    /// - **全バス出発済み**: 全て過去時刻 → "終了"
    /// - **日付跨ぎ**: 深夜0時前後のバスは自動補正（詳細は`parseNextBusDateTime`参照）
    ///
    /// ## 使用例
    /// ```swift
    /// let service = CountdownService()
    /// let buses = [/* NextBus配列 */]
    ///
    /// // 最速バスのカウントダウン
    /// let countdown = service.calculateCountdown(for: buses)
    /// // → "00:15:30"
    ///
    /// // 2番目のバスのカウントダウン
    /// let countdown = service.calculateCountdown(for: buses, selectedIndex: 1)
    /// // → "00:25:00"
    /// ```
    ///
    /// ## パフォーマンス
    /// - 時間計算量: O(n) where n = `infos.count`
    /// - 空間計算量: O(1)（定数メモリ使用）
    /// - selectedIndex指定時: O(1)（インデックスアクセスのみ）
    func calculateCountdown(for infos: [NextBus], selectedIndex: Int? = nil) -> String {
        let nextBusTime: Date?

        if let index = selectedIndex {
            // 選択されたバスのカウントダウンを計算
            nextBusTime = findBusTime(at: index, from: infos)
        } else {
            // デフォルト: 最も早いバスを自動選択
            nextBusTime = findNextBusTime(from: infos)
        }

        guard let busTime = nextBusTime else {
            return "終了"
        }

        let now = Date()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: busTime)

        guard let hour = diff.hour, let minute = diff.minute, let second = diff.second,
              hour >= 0, minute >= 0, second >= 0 else {
            return "出発"
        }

        if hour == 0 && minute == 0 && second < Constants.departureDisplayThreshold {
            return "出発"
        }

        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }

    /// バス出発時刻に必要時間を加算した到着時刻を計算
    ///
    /// ## 概要
    /// バスの出発時刻と所要時間から、目的地への到着時刻を計算します。
    /// HomeCardViewでの「出発時刻 → 到着時刻」表示に使用されます。
    ///
    /// ## パラメータ
    /// - Parameter time: 出発時刻（"HH:mm"形式の文字列）
    ///   - 例: "10:30", "23:45", "00:15"
    /// - Parameter requiredTime: 所要時間（分単位）
    ///   - 例: 15分、20分、30分
    ///
    /// ## 戻り値
    /// - **成功時**: 到着時刻（"HH:mm"形式）
    ///   - 例: "10:45", "00:05" (日付跨ぎ自動処理)
    /// - **失敗時**: "--:--"（パースエラー時）
    ///
    /// ## 計算例
    /// ```swift
    /// let service = CountdownService()
    ///
    /// // 通常の計算
    /// service.parseTime(time: "10:30", requiredTime: 15)
    /// // → "10:45"
    ///
    /// // 日付跨ぎ
    /// service.parseTime(time: "23:50", requiredTime: 20)
    /// // → "00:10"
    ///
    /// // パースエラー
    /// service.parseTime(time: "invalid", requiredTime: 15)
    /// // → "--:--"
    /// ```
    ///
    /// ## エラーケース
    /// - **不正な時刻形式**: "25:00", "abc", "" → "--:--"
    /// - **日付計算失敗**: カレンダー演算エラー → "--:--"
    ///
    /// ## 設計意図
    /// シンプルな時刻加算APIを提供することで、
    /// ViewModelやViewから日付計算の複雑さを隠蔽します。
    func parseTime(time: String, requiredTime: Int) -> String {
        guard let date = Self.cachedDateFormatter.date(from: time),
              let arrivalDate = Calendar.current.date(byAdding: .minute, value: requiredTime, to: date) else {
            return "--:--"
        }

        return Self.cachedDateFormatter.string(from: arrivalDate)
    }

    // MARK: - Private Methods

    /// 指定されたインデックスのバスの時刻を取得
    ///
    /// ## 概要
    /// ユーザーが選択したバスのインデックスから、
    /// そのバスの到着時刻をDate型で取得します。
    ///
    /// ## パラメータ
    /// - Parameter index: バスのインデックス（0ベース）
    /// - Parameter infos: 全バス情報の配列
    ///
    /// ## 戻り値
    /// - **成功時**: バスの到着時刻（Date型）
    /// - **失敗時**: nil（インデックス範囲外、またはパースエラー）
    ///
    /// ## 処理フロー
    /// 1. インデックスの範囲チェック
    /// 2. バス情報から時刻文字列を取得
    /// 3. `parseNextBusDateTime`で日付跨ぎ対応のDate変換
    ///
    /// ## エラーケース
    /// - `index < 0 || index >= infos.count` → nil
    /// - 時刻文字列のパース失敗 → nil
    private func findBusTime(at index: Int, from infos: [NextBus]) -> Date? {
        guard index >= 0 && index < infos.count else {
            return nil
        }

        let info = infos[index]
        let now = Date()
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)

        return parseNextBusDateTime(
            info.realArrivalTime,
            nowComponents: nowComponents,
            calendar: calendar,
            now: now
        )
    }

    /// 次に到着するバスの時刻を検索
    ///
    /// ## 概要
    /// 全バス情報から、現在時刻より後で最も早く到着するバスを検索します。
    /// ユーザーがバスを選択していない場合の自動選択ロジックです。
    ///
    /// ## パラメータ
    /// - Parameter infos: 全バス情報の配列
    ///
    /// ## 戻り値
    /// - **成功時**: 最も早いバスの到着時刻（Date型）
    /// - **失敗時**: nil（該当バスなし、または全バス出発済み）
    ///
    /// ## アルゴリズム
    /// 1. 全バス情報を順次走査
    /// 2. 各バスの時刻をDateに変換（日付跨ぎ対応）
    /// 3. 現在時刻より未来のバスのみ考慮
    /// 4. 最も早いバスを保持（min比較）
    ///
    /// ## パフォーマンス
    /// - 時間計算量: O(n) where n = `infos.count`
    /// - 空間計算量: O(1)
    ///
    /// ## 使用例（内部）
    /// ```swift
    /// let nextTime = findNextBusTime(from: busInfos)
    /// if let time = nextTime {
    ///     // 次のバスが存在
    /// } else {
    ///     // 全バス出発済み
    /// }
    /// ```
    private func findNextBusTime(from infos: [NextBus]) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)

        var nextBusTime: Date?

        for info in infos {
            guard let targetDateTime = parseNextBusDateTime(
                info.realArrivalTime,
                nowComponents: nowComponents,
                calendar: calendar,
                now: now
            ) else {
                continue
            }

            if targetDateTime > now {
                if let currentNext = nextBusTime {
                    if targetDateTime < currentNext {
                        nextBusTime = targetDateTime
                    }
                } else {
                    nextBusTime = targetDateTime
                }
            }
        }

        return nextBusTime
    }

    /// バスの到着時刻文字列を現在日時を基準にDateに変換
    ///
    /// ## 概要
    /// 時刻文字列（"HH:mm"）を現在の日付と組み合わせてDate型に変換します。
    /// 深夜0時を跨ぐバスを正しく処理するため、日付跨ぎ判定ロジックを含みます。
    ///
    /// ## パラメータ
    /// - Parameter timeString: バス到着時刻（"HH:mm"形式）
    /// - Parameter nowComponents: 現在日時のDateComponents（年月日）
    /// - Parameter formatter: 日付フォーマッター
    /// - Parameter calendar: カレンダー（日付計算用）
    /// - Parameter now: 現在時刻
    ///
    /// ## 戻り値
    /// - **成功時**: バスの到着時刻（Date型、日付跨ぎ補正済み）
    /// - **失敗時**: nil（パースエラー、または日付生成失敗）
    ///
    /// ## 日付跨ぎ判定ロジック（重要）
    /// 以下の条件を**全て**満たす場合、バスは「翌日の同時刻」と判定されます：
    /// 1. `targetDateTime < now`（バス時刻が現在時刻より過去）
    /// 2. `hourDiff < -12`（差分が-12時間未満）
    ///
    /// ### 判定例
    /// | 現在時刻 | バス時刻 | 差分 | 判定 | 理由 |
    /// |---------|---------|------|------|------|
    /// | 23:50   | 00:10   | -23h40m | 翌日 | 深夜バスとして正しい |
    /// | 23:30   | 00:45   | -22h45m | 翌日 | 深夜バスとして正しい |
    /// | 12:00   | 11:00   | -1h     | 過去 | 本当に過去のバス |
    /// | 01:00   | 23:00   | -2h     | 過去 | 前日のバス（対象外） |
    ///
    /// ## 設計意図
    /// 深夜0時前後（23:00〜01:00）のバス運行を正確に扱うため、
    /// 単純な時刻比較ではなく、-12時間閾値による判定を実装しています。
    ///
    /// ## エラーケース
    /// - `timeString`のパース失敗 → nil
    /// - DateComponents→Date変換失敗 → nil
    /// - 翌日計算失敗（稀） → 補正なしのDateを返す
    private func parseNextBusDateTime(
        _ timeString: String,
        nowComponents: DateComponents,
        calendar: Calendar,
        now: Date
    ) -> Date? {
        guard let time = Self.cachedDateFormatter.date(from: timeString) else {
            return nil
        }

        var targetComponents = calendar.dateComponents([.hour, .minute], from: time)
        targetComponents.year = nowComponents.year
        targetComponents.month = nowComponents.month
        targetComponents.day = nowComponents.day

        guard var targetDateTime = calendar.date(from: targetComponents) else {
            return nil
        }

        // 日付跨ぎの補正（深夜0時前後のバス対応）
        if targetDateTime < now,
           let hourDiff = calendar.dateComponents([.hour], from: now, to: targetDateTime).hour,
           hourDiff < Constants.midnightCrossoverThreshold {
            if let nextDayTarget = calendar.date(byAdding: .day, value: 1, to: targetDateTime) {
                targetDateTime = nextDayTarget
            }
        }

        return targetDateTime
    }
}
