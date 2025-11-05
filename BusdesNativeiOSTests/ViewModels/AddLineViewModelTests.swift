import XCTest
@testable import BusdesNativeiOS

/// AddLineViewModelのユニットテスト
///
/// ## テスト対象
/// - バス停データの読み込み
/// - 検索フィルタリングロジック
/// - エラーハンドリング
/// - 依存注入とテスタビリティ
@MainActor
final class AddLineViewModelTests: XCTestCase {

    // MARK: - Mock Repository

    /// テスト用モックBusStopRepository
    final class MockBusStopRepository: BusStopRepository {
        var shouldThrowError = false
        var mockBusStops: [BusStop] = []

        func getBusStops() throws -> [BusStop] {
            if shouldThrowError {
                throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            }
            return mockBusStops
        }
    }

    var mockRepository: MockBusStopRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockBusStopRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    /// 正常なデータ読み込みの確認
    func testInit_Success_LoadsAllBusStops() {
        // Given: モックリポジトリに3つのバス停データを設定
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "テストバス停", kana: "てすとばすてい")
        ]

        // When: ViewModelを初期化
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // Then: 全バス停が読み込まれ、filteredDataに設定される
        XCTAssertEqual(sut.state.filteredData.count, 3, "全バス停が読み込まれるべき")
        XCTAssertEqual(sut.state.filteredData[0].name, "立命館大学")
        XCTAssertEqual(sut.state.filteredData[1].name, "南草津駅")
        XCTAssertEqual(sut.state.filteredData[2].name, "テストバス停")
        XCTAssertFalse(sut.state.loadingState.isLoading, "ローディングは完了しているべき")
        XCTAssertNil(sut.state.loadingState.errorMessage, "エラーはないべき")
    }

    /// データ読み込み失敗時のエラーハンドリング確認
    func testInit_LoadFails_SetsErrorState() {
        // Given: リポジトリがエラーを投げるように設定
        mockRepository.shouldThrowError = true

        // When: ViewModelを初期化
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // Then: エラー状態が設定される
        XCTAssertTrue(sut.state.filteredData.isEmpty, "エラー時はfilteredDataは空であるべき")
        XCTAssertFalse(sut.state.loadingState.isLoading, "ローディングは完了しているべき")
        XCTAssertEqual(sut.state.loadingState.errorMessage, "バス停データの読み込みに失敗しました")
    }

    // MARK: - filterBusStops Tests

    /// 空クエリで全バス停が表示されることを確認
    func testFilterBusStops_EmptyQuery_ShowsAllStops() {
        // Given: 3つのバス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "テストバス停", kana: "てすとばすてい")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 空文字列でフィルタリング
        sut.filterBusStops(with: "")

        // Then: 全バス停が表示される
        XCTAssertEqual(sut.state.filteredData.count, 3, "空クエリの場合は全バス停が表示されるべき")
        XCTAssertEqual(sut.state.searchQuery, "", "searchQueryは空文字列であるべき")
    }

    /// バス停名（漢字）で部分一致フィルタリングを確認
    func testFilterBusStops_NameMatch_FiltersCorrectly() {
        // Given: 3つのバス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "立命館いばらきキャンパス", kana: "りつめいかんいばらききゃんぱす")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: "立命館"でフィルタリング
        sut.filterBusStops(with: "立命館")

        // Then: "立命館"を含むバス停のみ表示される
        XCTAssertEqual(sut.state.filteredData.count, 2, "「立命館」を含むバス停が2つフィルタされるべき")
        XCTAssertEqual(sut.state.filteredData[0].name, "立命館大学")
        XCTAssertEqual(sut.state.filteredData[1].name, "立命館いばらきキャンパス")
        XCTAssertEqual(sut.state.searchQuery, "立命館")
    }

    /// かな名で部分一致フィルタリングを確認
    func testFilterBusStops_KanaMatch_FiltersCorrectly() {
        // Given: 3つのバス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "草津駅", kana: "くさつえき")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: "くさつ"でフィルタリング
        sut.filterBusStops(with: "くさつ")

        // Then: "くさつ"を含むバス停のみ表示される
        XCTAssertEqual(sut.state.filteredData.count, 2, "「くさつ」を含むバス停が2つフィルタされるべき")
        XCTAssertTrue(sut.state.filteredData.contains { $0.name == "南草津駅" })
        XCTAssertTrue(sut.state.filteredData.contains { $0.name == "草津駅" })
        XCTAssertEqual(sut.state.searchQuery, "くさつ")
    }

    /// 一致なしの場合は空配列を返すことを確認
    func testFilterBusStops_NoMatch_ReturnsEmpty() {
        // Given: 3つのバス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "テストバス停", kana: "てすとばすてい")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 存在しない文字列でフィルタリング
        sut.filterBusStops(with: "存在しないバス停")

        // Then: 空配列が返される
        XCTAssertTrue(sut.state.filteredData.isEmpty, "一致なしの場合は空配列であるべき")
        XCTAssertEqual(sut.state.searchQuery, "存在しないバス停")
    }

    /// 大文字小文字を区別することを確認（日本語の場合は影響なし）
    func testFilterBusStops_CaseSensitive_ForJapanese() {
        // Given: バス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "ABC駅", kana: "えーびーしーえき"),
            BusStop(name: "abc駅", kana: "えーびーしーえき")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: 大文字でフィルタリング
        sut.filterBusStops(with: "ABC")

        // Then: 大文字小文字を区別する
        XCTAssertEqual(sut.state.filteredData.count, 1, "大文字小文字を区別すべき")
        XCTAssertEqual(sut.state.filteredData[0].name, "ABC駅")
    }

    /// 複数回のフィルタリングで状態が正しく更新されることを確認
    func testFilterBusStops_MultipleFilters_UpdatesStateCorrectly() {
        // Given: バス停データ
        mockRepository.mockBusStops = [
            BusStop(name: "立命館大学", kana: "りつめいかんだいがく"),
            BusStop(name: "南草津駅", kana: "みなみくさつえき"),
            BusStop(name: "草津駅", kana: "くさつえき")
        ]
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When & Then: 複数回フィルタリング
        // 1回目: "立命館"
        sut.filterBusStops(with: "立命館")
        XCTAssertEqual(sut.state.filteredData.count, 1)
        XCTAssertEqual(sut.state.searchQuery, "立命館")

        // 2回目: "くさつ"
        sut.filterBusStops(with: "くさつ")
        XCTAssertEqual(sut.state.filteredData.count, 2)
        XCTAssertEqual(sut.state.searchQuery, "くさつ")

        // 3回目: 空文字列（リセット）
        sut.filterBusStops(with: "")
        XCTAssertEqual(sut.state.filteredData.count, 3)
        XCTAssertEqual(sut.state.searchQuery, "")
    }

    /// 部分一致のパフォーマンスを確認（大量データ）
    func testFilterBusStops_LargeDataSet_PerformsWell() {
        // Given: 100個のバス停データ
        mockRepository.mockBusStops = (0..<100).map { index in
            BusStop(name: "バス停\(index)", kana: "ばすてい\(index)")
        }
        let sut = AddLineViewModel(busStopRepository: mockRepository)

        // When: パフォーマンス測定
        measure {
            sut.filterBusStops(with: "バス停")
        }

        // Then: 100個全てがフィルタされる
        XCTAssertEqual(sut.state.filteredData.count, 100, "全バス停がフィルタされるべき")
    }
}
