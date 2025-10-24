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
    /// 初期化時に自動的にバス停データを読み込む
    init(busStopRepository: BusStopRepository = BusStopRepository.shared) {
        self.busStopRepository = busStopRepository
        loadBusStops()
    }

    // MARK: - Private Methods

    /// バス停一覧をJSONファイルから読み込む
    ///
    /// 読み込み成功時は全バス停を`filteredData`に設定
    /// 失敗時はエラーメッセージを`loadingState`に格納
    private func loadBusStops() {
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

    // MARK: - Public Methods

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
