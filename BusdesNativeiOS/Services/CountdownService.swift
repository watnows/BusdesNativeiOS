import Foundation

/// カウントダウン計算とバス到着時刻処理を担当するサービス
struct CountdownService {
    // MARK: - Constants

    private enum Constants {
        static let timeZone = TimeZone(identifier: "Asia/Tokyo")!
        static let dateFormat = "HH:mm"
        static let midnightCrossoverThreshold = -12 // 日付跨ぎ判定の閾値（時間）
        static let departureDisplayThreshold = 5    // "出発"表示の秒数閾値
    }

    // MARK: - Public Methods

    /// 次のバス到着までのカウントダウン文字列を計算
    /// - Parameters:
    ///   - infos: 接近情報の配列
    ///   - selectedIndex: 選択されたバスのインデックス（nilの場合は最も早いバスを自動選択）
    /// - Returns: カウントダウン文字列（例: "00:15:30", "出発", "終了"）
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
    /// - Parameters:
    ///   - time: 出発時刻（"HH:mm"形式）
    ///   - requiredTime: 必要時間（分）
    /// - Returns: 到着時刻文字列（"HH:mm"形式）、解析失敗時は"--:--"
    func parseTime(time: String, requiredTime: Int) -> String {
        let dateFormatter = createDateFormatter()

        guard let date = dateFormatter.date(from: time),
              let arrivalDate = Calendar.current.date(byAdding: .minute, value: requiredTime, to: date) else {
            return "--:--"
        }

        return dateFormatter.string(from: arrivalDate)
    }

    // MARK: - Private Methods

    /// 指定されたインデックスのバスの時刻を取得
    private func findBusTime(at index: Int, from infos: [NextBus]) -> Date? {
        guard index >= 0 && index < infos.count else {
            return nil
        }

        let info = infos[index]
        let now = Date()
        let calendar = Calendar.current
        let formatter = createDateFormatter()
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)

        return parseNextBusDateTime(
            info.realArrivalTime,
            nowComponents: nowComponents,
            formatter: formatter,
            calendar: calendar,
            now: now
        )
    }

    /// 次に到着するバスの時刻を検索
    private func findNextBusTime(from infos: [NextBus]) -> Date? {
        let now = Date()
        let calendar = Calendar.current
        let formatter = createDateFormatter()
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)

        var nextBusTime: Date?

        for info in infos {
            guard let targetDateTime = parseNextBusDateTime(
                info.realArrivalTime,
                nowComponents: nowComponents,
                formatter: formatter,
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
    private func parseNextBusDateTime(
        _ timeString: String,
        nowComponents: DateComponents,
        formatter: DateFormatter,
        calendar: Calendar,
        now: Date
    ) -> Date? {
        guard let time = formatter.date(from: timeString) else {
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

    /// 日付フォーマッターを生成
    private func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Constants.timeZone
        return formatter
    }
}
