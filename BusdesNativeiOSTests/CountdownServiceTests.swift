//
//  CountdownServiceTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
@testable import BusdesNativeiOS

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

    // MARK: - Tests

    func testParseTime_ValidInput() {
        // Given: 有効な時刻と所要時間
        let busTime = "10:00"
        let requiredTime = 15

        // When: 到着時刻を計算
        let result = sut.parseTime(time: busTime, requiredTime: requiredTime)

        // Then: 正しく加算される
        XCTAssertEqual(result, "10:15")
    }

    func testParseTime_InvalidInput() {
        // Given: 無効な時刻フォーマット
        let invalidTime = "invalid"
        let requiredTime = 15

        // When: 到着時刻を計算
        let result = sut.parseTime(time: invalidTime, requiredTime: requiredTime)

        // Then: エラー表示が返る
        XCTAssertEqual(result, "--:--")
    }

    func testParseTime_MidnightCrossover() {
        // Given: 日付跨ぎが発生する時刻
        let busTime = "23:50"
        let requiredTime = 20

        // When: 到着時刻を計算
        let result = sut.parseTime(time: busTime, requiredTime: requiredTime)

        // Then: 翌日に正しく加算される
        XCTAssertEqual(result, "00:10")
    }

    func testCalculateCountdown_EmptyBusList() {
        // Given: 空のバスリスト
        let emptyBuses: [NextBus] = []

        // When: カウントダウンを計算
        let result = sut.calculateCountdown(for: emptyBuses)

        // Then: "終了"が返る
        XCTAssertEqual(result, "終了")
    }

    func testCalculateCountdown_WithFutureBus() {
        // Given: 未来の時刻のバス
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let futureDate = Date().addingTimeInterval(600) // 10分後
        let futureTime = formatter.string(from: futureDate)

        let buses = [
            NextBus(busTime: futureTime, realArrivalTime: futureTime, status: "接近")
        ]

        // When: カウントダウンを計算
        let result = sut.calculateCountdown(for: buses)

        // Then: カウントダウン形式の文字列が返る（HH:MM:SS）
        XCTAssertTrue(result.contains(":"), "Result should contain time format")
        XCTAssertNotEqual(result, "終了", "Should not show '終了' for future bus")
        XCTAssertNotEqual(result, "出発", "Should not show '出発' for future bus")
    }

    func testCalculateCountdown_WithPastBus() {
        // Given: 過去の時刻のバス
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let pastDate = Date().addingTimeInterval(-600) // 10分前
        let pastTime = formatter.string(from: pastDate)

        let buses = [
            NextBus(busTime: pastTime, realArrivalTime: pastTime, status: "接近")
        ]

        // When: カウントダウンを計算
        let result = sut.calculateCountdown(for: buses)

        // Then: "出発"または"終了"が返る
        XCTAssertTrue(result == "出発" || result == "終了", "Should show departure or end state for past bus")
    }

    func testCalculateCountdown_WithSelectedIndex() {
        // Given: 複数のバスと選択インデックス
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let future1 = Date().addingTimeInterval(300) // 5分後
        let future2 = Date().addingTimeInterval(900) // 15分後

        let buses = [
            NextBus(busTime: formatter.string(from: future1), realArrivalTime: formatter.string(from: future1), status: "接近"),
            NextBus(busTime: formatter.string(from: future2), realArrivalTime: formatter.string(from: future2), status: "接近")
        ]

        // When: 2番目のバスを指定してカウントダウン計算
        let result = sut.calculateCountdown(for: buses, selectedIndex: 1)

        // Then: カウントダウンが表示される
        XCTAssertTrue(result.contains(":"), "Should show countdown format")
        XCTAssertNotEqual(result, "終了", "Should not be ended")
    }

    func testCalculateCountdown_InvalidSelectedIndex() {
        // Given: 範囲外のインデックス
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let future = Date().addingTimeInterval(600)
        let buses = [
            NextBus(busTime: formatter.string(from: future), realArrivalTime: formatter.string(from: future), status: "接近")
        ]

        // When: 無効なインデックスでカウントダウン計算
        let result = sut.calculateCountdown(for: buses, selectedIndex: 10)

        // Then: "終了"が返る
        XCTAssertEqual(result, "終了")
    }
}
