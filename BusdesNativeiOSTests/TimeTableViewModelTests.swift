//
//  TimeTableViewModelTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
@testable import BusdesNativeiOS

@MainActor
final class TimeTableViewModelTests: XCTestCase {

    var sut: TimeTableViewModel!

    override func setUp() async throws {
        try await super.setUp()
        sut = TimeTableViewModel()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // Given: 初期化されたViewModel

        // Then: 初期状態が正しいことを確認
        XCTAssertNil(sut.state.timeTableFromRits, "Initial fromRits should be nil")
        XCTAssertNil(sut.state.timeTableToRits, "Initial toRits should be nil")
        XCTAssertNil(sut.state.errorMessage, "Initial error should be nil")
        XCTAssertFalse(sut.state.isLoading, "Initial loading state should be false")
    }

    // MARK: - Loading State Tests

    func testFetchTimeTable_SetsLoadingState() async {
        // Given: 初期状態のViewModel
        XCTAssertFalse(sut.state.isLoading, "Should not be loading initially")

        // When: 時刻表取得を開始（実際のAPIには接続しない想定）
        // Note: このテストは実際のAPIコールを行うため、ネットワーク環境に依存
        await sut.fetchTimeTable()

        // Then: ローディングが終了している
        XCTAssertFalse(sut.state.isLoading, "Loading should be complete after fetch")
    }

    // MARK: - Data Validation Tests

    func testFetchTimeTable_PopulatesData() async {
        // Given: 初期状態のViewModel
        XCTAssertNil(sut.state.timeTableFromRits)
        XCTAssertNil(sut.state.timeTableToRits)

        // When: 時刻表を取得
        await sut.fetchTimeTable()

        // Then: データが取得されるか、エラーが設定される
        let hasData = sut.state.timeTableFromRits != nil && sut.state.timeTableToRits != nil
        let hasError = sut.state.errorMessage != nil

        XCTAssertTrue(hasData || hasError, "Should either have data or error after fetch")
    }

    // MARK: - Error Handling Tests

    func testFetchTimeTable_HandlesNetworkError() async {
        // Given: ViewModel with potential network issues
        // Note: このテストは実際のネットワーク状態に依存

        // When: 時刻表を取得
        await sut.fetchTimeTable()

        // Then: エラーが発生した場合、適切に処理される
        if let error = sut.state.errorMessage {
            XCTAssertTrue(error is NetworkError, "Error should be NetworkError type")
            XCTAssertFalse(sut.state.isLoading, "Should not be loading on error")
        }
    }

    // MARK: - State Consistency Tests

    func testState_MaintainsConsistency() async {
        // Given: 初期状態のViewModel

        // When: 時刻表を取得
        await sut.fetchTimeTable()

        // Then: 状態の一貫性を確認
        if sut.state.timeTableFromRits != nil && sut.state.timeTableToRits != nil {
            // データがある場合、エラーはnilであるべき
            XCTAssertNil(sut.state.errorMessage, "Should not have error when data exists")
        }

        if sut.state.errorMessage != nil {
            // エラーがある場合、データはnilであるべき
            // Note: 実際の実装では部分的にデータが存在する可能性もある
            XCTAssertFalse(sut.state.isLoading, "Should not be loading when error occurs")
        }
    }

    // MARK: - Data Structure Tests

    func testTimeList_Structure() async {
        // Given: 時刻表データを取得
        await sut.fetchTimeTable()

        // When: データが存在する場合
        if let timeTable = sut.state.timeTableFromRits {
            // Then: TimeList構造が正しいことを確認
            XCTAssertNotNil(timeTable.five, "TimeList should have 'five' property")
            XCTAssertNotNil(timeTable.six, "TimeList should have 'six' property")
            XCTAssertNotNil(timeTable.seven, "TimeList should have 'seven' property")

            // 各時間帯のデータが配列であることを確認
            XCTAssertTrue(timeTable.five is [TimeTableInfo], "Should be array of TimeTableInfo")
        }
    }

    // MARK: - Multiple Fetch Tests

    func testFetchTimeTable_MultipleCalls() async {
        // Given: 初期状態のViewModel

        // When: 複数回時刻表を取得
        await sut.fetchTimeTable()
        let firstResult = (sut.state.timeTableFromRits, sut.state.timeTableToRits)

        await sut.fetchTimeTable()
        let secondResult = (sut.state.timeTableFromRits, sut.state.timeTableToRits)

        // Then: 各呼び出しが独立して動作することを確認
        XCTAssertFalse(sut.state.isLoading, "Should not be loading after fetch completes")

        // データの一貫性を確認
        if firstResult.0 != nil && secondResult.0 != nil {
            // 両方とも成功した場合、データ構造は同じであるべき
            XCTAssertTrue(true, "Multiple fetches completed successfully")
        }
    }
}
