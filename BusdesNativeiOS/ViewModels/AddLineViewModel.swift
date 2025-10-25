import Foundation
import Observation

/// バス停選択画面のViewModel
/// @Observableパターンで状態管理を簡素化
@MainActor
@Observable
final class AddLineViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    struct State {
        var searchQuery: String = ""
        var filteredData: [BusStop] = []
        var loadingState = LoadingState()
    }

    var state = State()

    // MARK: - Dependencies

    private var busStops: [BusStop] = []
    private let busStopRepository: BusStopRepository

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameter busStopRepository: バス停データリポジトリ（テスト用にカスタマイズ可能）
    ///
    /// ## Swift 6並行処理対応
    /// `nonisolated`により、@MainActorクラス内でも同期的な初期化が可能
    /// デフォルトRepositoryの使用は`makeDefault()`ファクトリメソッドを推奨
    ///
    /// ## 使用例
    /// ```swift
    /// // 通常の使用（デフォルトRepository）
    /// let viewModel = AddLineViewModel.makeDefault()
    ///
    /// // テスト用（カスタムRepository）
    /// let viewModel = AddLineViewModel(busStopRepository: mockRepository)
    /// ```
    nonisolated init(busStopRepository: BusStopRepository) {
        self.busStopRepository = busStopRepository
        // loadBusStops()は@MainActorメソッドのため、初期化後に呼び出す必要あり
        // 実際のロードはViewのonAppearで実行される想定
    }

    /// デフォルトRepositoryを使用するViewModelを生成
    /// - Returns: デフォルトのBusStopRepositoryを使用するViewModel
    static func makeDefault() -> AddLineViewModel {
        AddLineViewModel(busStopRepository: BusStopRepository.shared)
    }

    // MARK: - Public Methods

    /// バス停一覧をJSONファイルから読み込む
    ///
    /// 読み込み成功時は全バス停を`filteredData`に設定
    /// 失敗時はエラーメッセージを`loadingState`に格納
    ///
    /// ## 使用例
    /// ```swift
    /// let viewModel = AddLineViewModel()
    /// await viewModel.loadBusStops()  // Viewのinit後に呼び出し
    /// ```
    func loadBusStops() {
        state.loadingState.startLoading()

        do {
            busStops = try busStopRepository.getBusStops()
            state.filteredData = busStops
            state.loadingState.finishLoading()
        } catch {
            busStops = []
            state.filteredData = []
            state.loadingState.failLoading(with: "バス停データの読み込みに失敗しました")
        }
    }

    /// 検索クエリでバス停をフィルタリング
    /// - Parameter query: 検索文字列（バス停名・かな名の部分一致で検索）
    ///
    /// クエリが空の場合は全バス停を表示
    func filterBusStops(with query: String) {
        state.searchQuery = query

        if query.isEmpty {
            state.filteredData = busStops
        } else {
            state.filteredData = busStops.filter {
                $0.name.contains(query) || $0.kana.contains(query)
            }
        }
    }
}
