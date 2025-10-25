import XCTest
@testable import BusdesNativeiOS

/// CountdownServiceのユニットテスト
///
/// ## テスト対象
/// - カウントダウン計算ロジック
/// - 日付跨ぎ処理（深夜0時前後のバス）
/// - 到着時刻計算
/// - エラーハンドリング
final class CountdownServiceTests: XCTestCase {

    var sut: CountdownService!

    override func setUp() {
        super.setUp()
        sut = CountdownService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - calculateCountdown Tests

    /// 空配列の場合は"終了"を返すことを確認
    func testCalculateCountdown_EmptyArray_ReturnsFinished() {
        let result = sut.calculateCountdown(for: [])
        XCTAssertEqual(result, "終了", "空配列の場合は「終了」を返すべき")
    }

    /// 無効なインデックスの場合は"終了"を返すことを確認
    func testCalculateCountdown_InvalidIndex_ReturnsFinished() {
        let buses = [
            NextBus(realArrivalTime: "10:30", via: "経路A", requiredTime: 15, busStop: "1")
        ]

        let result1 = sut.calculateCountdown(for: buses, selectedIndex: -1)
        XCTAssertEqual(result1, "終了", "負のインデックスの場合は「終了」を返すべき")

        let result2 = sut.calculateCountdown(for: buses, selectedIndex: 10)
        XCTAssertEqual(result2, "終了", "範囲外のインデックスの場合は「終了」を返すべき")
    }

    /// 過去の時刻の場合は"出発"を返すことを確認
    func testCalculateCountdown_PastTime_ReturnsDeparted() {
        let calendar = Calendar.current
        let now = Date()

        // 10分前の時刻を生成
        guard let pastTime = calendar.date(byAdding: .minute, value: -10, to: now) else {
            XCTFail("過去時刻の生成に失敗")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let pastTimeString = formatter.string(from: pastTime)

        let buses = [
            NextBus(realArrivalTime: pastTimeString, via: "経路A", requiredTime: 15, busStop: "1")
        ]

        let result = sut.calculateCountdown(for: buses)
        XCTAssertEqual(result, "出発", "過去の時刻の場合は「出発」を返すべき")
    }

    /// 5秒未満の場合は"出発"を返すことを確認
    func testCalculateCountdown_LessThan5Seconds_ReturnsDeparted() {
        let calendar = Calendar.current
        let now = Date()

        // 3秒後の時刻を生成
        guard let futureTime = calendar.date(byAdding: .second, value: 3, to: now) else {
            XCTFail("未来時刻の生成に失敗")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let futureTimeString = formatter.string(from: futureTime)

        let buses = [
            NextBus(realArrivalTime: futureTimeString, via: "経路A", requiredTime: 15, busStop: "1")
        ]

        let result = sut.calculateCountdown(for: buses)
        XCTAssertEqual(result, "出発", "5秒未満の場合は「出発」を返すべき")
    }

    /// 正常なカウントダウン文字列のフォーマットを確認
    func testCalculateCountdown_ValidTime_ReturnsFormattedString() {
        let calendar = Calendar.current
        let now = Date()

        // 15分後の時刻を生成
        guard let futureTime = calendar.date(byAdding: .minute, value: 15, to: now) else {
            XCTFail("未来時刻の生成に失敗")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let futureTimeString = formatter.string(from: futureTime)

        let buses = [
            NextBus(realArrivalTime: futureTimeString, via: "経路A", requiredTime: 15, busStop: "1")
        ]

        let result = sut.calculateCountdown(for: buses)

        // フォーマット検証: HH:MM:SS形式
        let pattern = #"^\d{2}:\d{2}:\d{2}$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(result.startIndex..., in: result)

        XCTAssertNotNil(regex.firstMatch(in: result, range: range), "カウントダウンはHH:MM:SS形式であるべき")

        // 時間が14-16分の範囲内（計算誤差を考慮）
        let components = result.split(separator: ":")
        if components.count == 3,
           let minutes = Int(components[1]) {
            XCTAssertTrue(minutes >= 14 && minutes <= 16, "カウントダウンの分は14-16分の範囲内であるべき")
        } else {
            XCTFail("カウントダウン文字列のパースに失敗")
        }
    }

    /// 複数バスから最速バスを選択することを確認
    func testCalculateCountdown_MultipleB uses_SelectsEarliest() {
        let calendar = Calendar.current
        let now = Date()

        // 10分後、20分後、5分後の時刻を生成
        guard let time1 = calendar.date(byAdding: .minute, value: 10, to: now),
              let time2 = calendar.date(byAdding: .minute, value: 20, to: now),
              let time3 = calendar.date(byAdding: .minute, value: 5, to: now) else {
            XCTFail("未来時刻の生成に失敗")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let buses = [
            NextBus(realArrivalTime: formatter.string(from: time1), via: "経路A", requiredTime: 15, busStop: "1"),
            NextBus(realArrivalTime: formatter.string(from: time2), via: "経路B", requiredTime: 15, busStop: "2"),
            NextBus(realArrivalTime: formatter.string(from: time3), via: "経路C", requiredTime: 15, busStop: "3")
        ]

        let result = sut.calculateCountdown(for: buses)

        // 最も早いバス（5分後）が選択されているか確認
        let components = result.split(separator: ":")
        if components.count == 3,
           let minutes = Int(components[1]) {
            XCTAssertTrue(minutes >= 4 && minutes <= 6, "最も早いバス（5分後）が選択されるべき")
        } else {
            XCTFail("カウントダウン文字列のパースに失敗")
        }
    }

    /// 指定されたインデックスのバスが選択されることを確認
    func testCalculateCountdown_SelectedIndex_UsesSpecifiedBus() {
        let calendar = Calendar.current
        let now = Date()

        // 5分後、10分後の時刻を生成
        guard let time1 = calendar.date(byAdding: .minute, value: 5, to: now),
              let time2 = calendar.date(byAdding: .minute, value: 10, to: now) else {
            XCTFail("未来時刻の生成に失敗")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let buses = [
            NextBus(realArrivalTime: formatter.string(from: time1), via: "経路A", requiredTime: 15, busStop: "1"),
            NextBus(realArrivalTime: formatter.string(from: time2), via: "経路B", requiredTime: 15, busStop: "2")
        ]

        // インデックス1（10分後のバス）を選択
        let result = sut.calculateCountdown(for: buses, selectedIndex: 1)

        let components = result.split(separator: ":")
        if components.count == 3,
           let minutes = Int(components[1]) {
            XCTAssertTrue(minutes >= 9 && minutes <= 11, "選択されたバス（10分後）が使用されるべき")
        } else {
            XCTFail("カウントダウン文字列のパースに失敗")
        }
    }

    // MARK: - parseTime Tests

    /// 正常な時刻加算を確認
    func testParseTime_ValidTime_ReturnsCorrectArrival() {
        let result = sut.parseTime(time: "10:30", requiredTime: 15)
        XCTAssertEqual(result, "10:45", "10:30 + 15分 = 10:45であるべき")
    }

    /// 日付跨ぎ（深夜0時）の時刻加算を確認
    func testParseTime_MidnightCrossover_HandlesCorrectly() {
        let result = sut.parseTime(time: "23:50", requiredTime: 20)
        XCTAssertEqual(result, "00:10", "23:50 + 20分 = 00:10（日付跨ぎ）であるべき")
    }

    /// 60分以上の時刻加算を確認
    func testParseTime_MoreThan60Minutes_HandlesCorrectly() {
        let result = sut.parseTime(time: "10:30", requiredTime: 90)
        XCTAssertEqual(result, "12:00", "10:30 + 90分 = 12:00であるべき")
    }

    /// 不正な時刻形式のエラーハンドリングを確認
    func testParseTime_InvalidTimeFormat_ReturnsErrorString() {
        let result1 = sut.parseTime(time: "25:00", requiredTime: 15)
        XCTAssertEqual(result1, "--:--", "不正な時刻形式は--:--を返すべき")

        let result2 = sut.parseTime(time: "invalid", requiredTime: 15)
        XCTAssertEqual(result2, "--:--", "不正な時刻形式は--:--を返すべき")

        let result3 = sut.parseTime(time: "", requiredTime: 15)
        XCTAssertEqual(result3, "--:--", "空文字列は--:--を返すべき")
    }

    /// 0分加算の場合を確認
    func testParseTime_ZeroRequiredTime_ReturnsSameTime() {
        let result = sut.parseTime(time: "10:30", requiredTime: 0)
        XCTAssertEqual(result, "10:30", "0分加算の場合は同じ時刻を返すべき")
    }

    /// 負の所要時間のエラーハンドリングを確認
    func testParseTime_NegativeRequiredTime_ReturnsCorrectTime() {
        let result = sut.parseTime(time: "10:30", requiredTime: -15)
        XCTAssertEqual(result, "10:15", "負の所要時間も正しく処理されるべき")
    }
}
