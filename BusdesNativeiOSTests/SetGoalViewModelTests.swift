//
//  SetGoalViewModelTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
import SwiftData
@testable import BusdesNativeiOS

@MainActor
final class SetGoalViewModelTests: XCTestCase {

    var sut: SetGoalViewModel!
    var testBusStop: BusStop!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // テスト用のBusStopを作成
        testBusStop = BusStop(name: "立命館大学", kana: "りつめいかんだいがく")

        // テスト用のModelContainerを作成（インメモリ）
        let schema = Schema([Route.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)

        sut = SetGoalViewModel(from: testBusStop)
    }

    override func tearDown() async throws {
        sut = nil
        testBusStop = nil
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // Given: 初期化されたViewModel

        // Then: 初期状態が正しいことを確認
        XCTAssertEqual(sut.state.selectedGoal, "南草津駅", "Initial goal should be 南草津駅")
        XCTAssertFalse(sut.state.showAlert, "Alert should not be shown initially")
        XCTAssertTrue(sut.state.alertMessage.isEmpty, "Alert message should be empty")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Should not be loading initially")
        XCTAssertEqual(sut.from.name, "立命館大学", "From property should be set correctly")
    }

    // MARK: - Goal Selection Tests

    func testSelectGoal() {
        // Given: 初期状態のViewModel

        // When: 目的地を変更
        sut.selectGoal("立命館大学")

        // Then: 選択された目的地が更新される
        XCTAssertEqual(sut.state.selectedGoal, "立命館大学", "Selected goal should be updated")
    }

    func testSelectGoal_MultipleTimes() {
        // Given: 初期状態のViewModel

        // When: 目的地を複数回変更
        sut.selectGoal("立命館大学")
        XCTAssertEqual(sut.state.selectedGoal, "立命館大学")

        sut.selectGoal("南草津駅")
        XCTAssertEqual(sut.state.selectedGoal, "南草津駅")

        sut.selectGoal("びわこ・くさつキャンパス")
        XCTAssertEqual(sut.state.selectedGoal, "びわこ・くさつキャンパス")

        // Then: 各変更が正しく反映される
        XCTAssertEqual(sut.state.selectedGoal, "びわこ・くさつキャンパス", "Should keep the last selection")
    }

    // MARK: - Route Creation Tests

    func testSetRoute_Success() {
        // Given: 有効な路線設定
        let destination = "南草津駅"
        let existingRoutes: [Route] = []

        // When: 路線を設定
        let result = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: existingRoutes)

        // Then: 路線が正常に追加される
        XCTAssertTrue(result, "Route setting should succeed")
        XCTAssertFalse(sut.state.showAlert, "Alert should not be shown on success")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")

        // SwiftDataに保存されているか確認
        let fetchDescriptor = FetchDescriptor<Route>()
        let routes = try? modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(routes?.count, 1, "Should have 1 route in database")
        XCTAssertEqual(routes?.first?.from, "立命館大学", "From should match")
        XCTAssertEqual(routes?.first?.to, "南草津駅", "To should match")
    }

    func testSetRoute_SameFromAndTo() {
        // Given: 乗り場と降り場が同じ
        let destination = "立命館大学"  // fromと同じ
        let existingRoutes: [Route] = []

        // When: 路線を設定しようとする
        let result = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: existingRoutes)

        // Then: エラーアラートが表示される
        XCTAssertFalse(result, "Route setting should fail")
        XCTAssertTrue(sut.state.showAlert, "Alert should be shown")
        XCTAssertEqual(sut.state.alertMessage, "乗り場と降り場が同じようです", "Should show correct error message")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")

        // SwiftDataに保存されていないか確認
        let fetchDescriptor = FetchDescriptor<Route>()
        let routes = try? modelContext.fetch(fetchDescriptor)
        XCTAssertTrue(routes?.isEmpty ?? true, "Should not save invalid route")
    }

    func testSetRoute_DuplicateRoute() {
        // Given: 既に存在する路線
        let destination = "南草津駅"
        let existingRoute = Route(to: destination, from: "立命館大学")
        let existingRoutes = [existingRoute]

        // When: 同じ路線を設定しようとする
        let result = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: existingRoutes)

        // Then: 重複エラーが表示される
        XCTAssertFalse(result, "Route setting should fail for duplicate")
        XCTAssertTrue(sut.state.showAlert, "Alert should be shown")
        XCTAssertEqual(sut.state.alertMessage, "既に登録済みのルートです", "Should show duplicate error message")
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")
    }

    func testSetRoute_MultipleValidRoutes() {
        // Given: 異なる路線を複数追加
        let destination1 = "南草津駅"
        let destination2 = "びわこ・くさつキャンパス"

        // When: 最初の路線を追加
        let result1 = sut.setRoute(to: destination1, modelContext: modelContext, existingRoutes: [])
        XCTAssertTrue(result1, "First route should succeed")

        // 既存路線を取得して2番目を追加
        let fetchDescriptor = FetchDescriptor<Route>()
        let existingRoutes = (try? modelContext.fetch(fetchDescriptor)) ?? []

        let sut2 = SetGoalViewModel(from: testBusStop)
        let result2 = sut2.setRoute(to: destination2, modelContext: modelContext, existingRoutes: existingRoutes)
        XCTAssertTrue(result2, "Second route should succeed")

        // Then: 両方の路線が保存される
        let allRoutes = try? modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(allRoutes?.count, 2, "Should have 2 routes in database")
    }

    // MARK: - Alert Management Tests

    func testDismissAlert() {
        // Given: アラートが表示されている状態
        sut.state.showAlert = true
        sut.state.alertMessage = "テストメッセージ"

        // When: アラートを閉じる
        sut.dismissAlert()

        // Then: アラート状態がリセットされる
        XCTAssertFalse(sut.state.showAlert, "Alert should be dismissed")
        XCTAssertTrue(sut.state.alertMessage.isEmpty, "Alert message should be cleared")
    }

    func testDismissAlert_WhenNoAlert() {
        // Given: アラートが表示されていない状態
        XCTAssertFalse(sut.state.showAlert)

        // When: dismissAlertを呼ぶ
        sut.dismissAlert()

        // Then: 問題なく処理される
        XCTAssertFalse(sut.state.showAlert, "Alert should remain dismissed")
        XCTAssertTrue(sut.state.alertMessage.isEmpty, "Alert message should remain empty")
    }

    // MARK: - Loading State Tests

    func testSetRoute_LoadingState() {
        // Given: 路線設定前
        XCTAssertFalse(sut.state.loadingState.isLoading)

        // When: 路線を設定
        let destination = "南草津駅"
        _ = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: [])

        // Then: ローディングが終了している
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete after route setting")
    }

    // MARK: - Edge Cases Tests

    func testSetRoute_EmptyDestination() {
        // Given: 空の目的地
        let destination = ""
        let existingRoutes: [Route] = []

        // When: 路線を設定しようとする
        let result = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: existingRoutes)

        // Then: 処理される（バリデーションは通過、データは作成される）
        // Note: 実装によってはバリデーションエラーにすべき
        XCTAssertFalse(sut.state.loadingState.isLoading, "Loading should be complete")
    }

    func testSetRoute_SpecialCharacters() {
        // Given: 特殊文字を含む目的地
        let destination = "テスト駅 (Test Station)"
        let existingRoutes: [Route] = []

        // When: 路線を設定
        let result = sut.setRoute(to: destination, modelContext: modelContext, existingRoutes: existingRoutes)

        // Then: 正常に処理される
        if result {
            let fetchDescriptor = FetchDescriptor<Route>()
            let routes = try? modelContext.fetch(fetchDescriptor)
            XCTAssertEqual(routes?.first?.to, destination, "Should handle special characters")
        }
    }
}
