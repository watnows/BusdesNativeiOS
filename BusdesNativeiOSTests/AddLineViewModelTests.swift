//
//  AddLineViewModelTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
@testable import BusdesNativeiOS

@MainActor
final class AddLineViewModelTests: XCTestCase {

    var sut: AddLineViewModel!
    var mockRepository: MockBusStopRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockBusStopRepository()
        sut = AddLineViewModel(busStopRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // Given: 初期化されたViewModel

        // Then: 初期状態が正しいことを確認
        XCTAssertTrue(sut.state.searchQuery.isEmpty, "Initial search query should be empty")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Should not be loading after initialization")
    }

    // MARK: - Data Loading Tests

    func testLoadBusStops_Success() {
        // Given: モックリポジトリが成功レスポンスを返す
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "びわこ・くさつキャンパス", kana: "びわこくさつきゃんぱす")
        ]
        mockRepository.mockBusStops = mockBusStops
        mockRepository.shouldThrowError = false

        // When: ViewModelを初期化（自動でloadBusStopsが呼ばれる）
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // Then: データが正しく読み込まれる
        XCTAssertEqual(sut.state.filteredData.count, 3, "Should load 3 bus stops")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")
        XCTAssertNil(sut.state.loadingState.errorMessage, "Should have no error")
    }

    func testLoadBusStops_Failure() {
        // Given: モックリポジトリがエラーを返す
        mockRepository.shouldThrowError = true

        // When: ViewModelを初期化
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // Then: エラーが適切に処理される
        XCTAssertTrue(sut.state.filteredData.isEmpty, "Filtered data should be empty on error")
        XCTAssertNotNil(sut.state.loadingState.errorMessage, "Should have error message")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")
    }

    // MARK: - Search/Filter Tests

    func testFilterBusStops_EmptyQuery() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 空の検索クエリでフィルタリング
        sut.filterBusStops(with: "")

        // Then: 全てのバス停が表示される
        XCTAssertEqual(sut.state.filteredData.count, 2, "Should show all bus stops")
        XCTAssertTrue(sut.state.searchQuery.isEmpty, "Search query should be empty")
    }

    func testFilterBusStops_ByName() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "立命館大学前", kana: "りつめいかんだいがくまえ")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: "立命館"で検索
        sut.filterBusStops(with: "立命館")

        // Then: マッチするバス停のみ表示される
        XCTAssertEqual(sut.state.filteredData.count, 2, "Should find 2 matching bus stops")
        XCTAssertTrue(sut.state.filteredData.allSatisfy { $0.name.contains("立命館") },
                     "All results should contain search term")
        XCTAssertEqual(sut.state.searchQuery, "立命館", "Search query should be updated")
    }

    func testFilterBusStops_ByKana() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: かな名で検索
        sut.filterBusStops(with: "みなみ")

        // Then: かな名でマッチするバス停が表示される
        XCTAssertEqual(sut.state.filteredData.count, 1, "Should find 1 matching bus stop")
        XCTAssertEqual(sut.state.filteredData.first?.name, "南草津駅", "Should find correct bus stop")
    }

    func testFilterBusStops_NoMatches() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: マッチしない文字列で検索
        sut.filterBusStops(with: "存在しないバス停")

        // Then: 結果が空になる
        XCTAssertTrue(sut.state.filteredData.isEmpty, "Should return empty results")
        XCTAssertEqual(sut.state.searchQuery, "存在しないバス停", "Search query should be updated")
    }

    // MARK: - Multiple Filter Tests

    func testFilterBusStops_MultipleCalls() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "立命館大学前", kana: "りつめいかんだいがくまえ")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 複数回フィルタリングを実行
        sut.filterBusStops(with: "立命館")
        XCTAssertEqual(sut.state.filteredData.count, 2, "First filter should find 2")

        sut.filterBusStops(with: "南草津")
        XCTAssertEqual(sut.state.filteredData.count, 1, "Second filter should find 1")

        sut.filterBusStops(with: "")
        XCTAssertEqual(sut.state.filteredData.count, 3, "Empty filter should show all")

        // Then: 各フィルタリングが独立して動作
        XCTAssertTrue(sut.state.searchQuery.isEmpty, "Final search query should be empty")
    }

    // MARK: - Case Sensitivity Tests

    func testFilterBusStops_CaseSensitivity() {
        // Given: バス停データがロード済み
        let mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく")
        ]
        mockRepository.mockBusStops = mockBusStops
        sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 大文字・小文字を含む検索（日本語なので影響なし）
        sut.filterBusStops(with: "立命館")

        // Then: 正しく検索される
        XCTAssertEqual(sut.state.filteredData.count, 1, "Should find the bus stop")
    }
}

// MARK: - Mock Objects

final class MockBusStopRepository: BusStopRepository {
    var mockBusStops: [BusStop] = []
    var shouldThrowError = false

    override func getBusStops() throws -> [BusStop] {
        if shouldThrowError {
            throw NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return mockBusStops
    }
}
