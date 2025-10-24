//
//  HomeViewModelTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
@testable import BusdesNativeiOS

@MainActor
final class HomeViewModelTests: XCTestCase {

    var sut: HomeViewModel!
    var mockAPIService: MockBusAPIService!

    override func setUp() async throws {
        try await super.setUp()
        mockAPIService = MockBusAPIService()
        sut = HomeViewModel(apiService: mockAPIService)
    }

    override func tearDown() async throws {
        sut = nil
        mockAPIService = nil
        try await super.tearDown()
    }

    // MARK: - Tests

    func testInitialState() {
        // Given: 初期化されたViewModel

        // Then: 初期状態が空であることを確認
        XCTAssertTrue(sut.timeTables.isEmpty, "Initial timeTables should be empty")
        XCTAssertTrue(sut.countdowns.isEmpty, "Initial countdowns should be empty")
        XCTAssertTrue(sut.selectedBusIndices.isEmpty, "Initial selectedBusIndices should be empty")
        XCTAssertTrue(sut.errorMessages.isEmpty, "Initial errorMessages should be empty")
    }

    func testFetchTimeTable_Success() async {
        // Given: モックAPIが成功レスポンスを返す設定
        let testRoute = Route(to: "TestTo", from: "TestFrom")
        let mockResponse = ApproachInfo(
            busStopName: "Test Stop",
            approachInfos: [
                NextBus(busTime: "10:00", realArrivalTime: "10:00", status: "接近"),
                NextBus(busTime: "10:30", realArrivalTime: "10:30", status: "接近")
            ]
        )
        mockAPIService.mockResponse = .success(mockResponse)

        // When: バス時刻表を取得
        await sut.startRealtimeUpdates(for: [testRoute])

        // Then: データが正しく格納される
        XCTAssertFalse(sut.timeTables.isEmpty, "TimeTables should not be empty after fetch")
        XCTAssertEqual(sut.timeTables[testRoute.id]?.count, 2, "Should have 2 buses")
        XCTAssertNil(sut.errorMessages[testRoute.id], "Should have no error")
    }

    func testFetchTimeTable_Failure() async {
        // Given: モックAPIがエラーを返す設定
        let testRoute = Route(to: "TestTo", from: "TestFrom")
        mockAPIService.mockResponse = .failure(.networkError(URLError(.notConnectedToInternet)))

        // When: バス時刻表を取得
        await sut.startRealtimeUpdates(for: [testRoute])

        // Then: エラーが適切に処理される
        XCTAssertTrue(sut.timeTables[testRoute.id]?.isEmpty ?? true, "TimeTables should be empty on error")
        XCTAssertNotNil(sut.errorMessages[testRoute.id], "Should have error message")
        XCTAssertEqual(sut.countdowns[testRoute.id], "---", "Countdown should show error state")
    }

    func testSelectBus() {
        // Given: バス情報が存在する状態
        let testRoute = Route(to: "TestTo", from: "TestFrom")
        let testBuses = [
            NextBus(busTime: "10:00", realArrivalTime: "10:00", status: "接近"),
            NextBus(busTime: "10:30", realArrivalTime: "10:30", status: "接近")
        ]
        sut.timeTables[testRoute.id] = testBuses

        // When: 2番目のバスを選択
        sut.selectBus(at: 1, for: testRoute.id)

        // Then: 選択インデックスが更新される
        XCTAssertEqual(sut.selectedBusIndices[testRoute.id], 1, "Selected bus index should be 1")
    }

    func testResetAllSelections() {
        // Given: 複数の選択状態がある
        let route1 = Route(to: "To1", from: "From1")
        let route2 = Route(to: "To2", from: "From2")
        sut.selectedBusIndices[route1.id] = 0
        sut.selectedBusIndices[route2.id] = 1

        // When: すべての選択をリセット
        sut.resetAllSelections()

        // Then: すべての選択がクリアされる
        XCTAssertTrue(sut.selectedBusIndices.isEmpty, "All selections should be cleared")
    }

    func testUpdateRoutes_RemovesOldData() async {
        // Given: 古いルートのデータが存在
        let oldRoute = Route(to: "OldTo", from: "OldFrom")
        let newRoute = Route(to: "NewTo", from: "NewFrom")

        sut.timeTables[oldRoute.id] = []
        sut.errorMessages[oldRoute.id] = nil
        sut.countdowns[oldRoute.id] = "00:10:00"

        mockAPIService.mockResponse = .success(ApproachInfo(busStopName: "Test", approachInfos: []))

        // When: 新しいルートリストに更新
        await sut.updateRoutes([newRoute])

        // Then: 古いデータが削除される
        XCTAssertNil(sut.timeTables[oldRoute.id], "Old route data should be removed")
        XCTAssertNil(sut.errorMessages[oldRoute.id], "Old error should be removed")
        XCTAssertNil(sut.countdowns[oldRoute.id], "Old countdown should be removed")
    }

    func testParseTime() {
        // Given: 時刻文字列と所要時間
        let busTime = "10:00"
        let requiredTime = 15

        // When: 到着時刻を計算
        let arrivalTime = sut.parseTime(time: busTime, requiredTime: requiredTime)

        // Then: 正しく加算される
        XCTAssertEqual(arrivalTime, "10:15", "Arrival time should be correctly calculated")
    }
}

// MARK: - Mock Objects

final class MockBusAPIService: BusAPIServiceProtocol {
    var mockResponse: Result<ApproachInfo, NetworkError>?
    var fetchCallCount = 0

    func fetchNextBus(from: String, to: String) async throws -> ApproachInfo {
        fetchCallCount += 1

        guard let result = mockResponse else {
            throw NetworkError.unknownError(NSError(domain: "test", code: -1))
        }

        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    func fetchTimeTable(from: String, to: String) async throws -> TimeTable {
        // TimeTableモックは必要に応じて実装
        throw NetworkError.unknownError(NSError(domain: "test", code: -1))
    }
}
