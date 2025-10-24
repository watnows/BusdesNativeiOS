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
        var errorMessage: String? = nil
    }

    var state = State()

    // MARK: - Dependencies

    private var busStops: [BusStop] = []
    private let busStopRepository: BusStopRepository

    // MARK: - Initialization

    init(busStopRepository: BusStopRepository = BusStopRepository.shared) {
        self.busStopRepository = busStopRepository
        loadBusStops()
    }

    // MARK: - Public Methods

    /// バス停一覧を読み込む
    private func loadBusStops() {
        do {
            busStops = try busStopRepository.getBusStops()
            state.filteredData = busStops
            state.errorMessage = nil
        } catch {
            busStops = []
            state.filteredData = []
            state.errorMessage = "バス停データの読み込みに失敗しました"
        }
    }

    /// 検索クエリでバス停をフィルタリング
    /// - Parameter query: 検索文字列
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
