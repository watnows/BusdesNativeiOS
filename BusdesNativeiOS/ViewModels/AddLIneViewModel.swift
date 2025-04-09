import Combine
import Foundation

class AddLineViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var filteredData: [BusStopModel] = []

    private var busStops = BusStopModel.dataList

    init(busStops: [BusStopModel]) {
        self.busStops = busStops
        self.filteredData = busStops
    }

    func filterBusStops(with query: String) {
        if query.isEmpty {
            filteredData = busStops
        } else {
            filteredData = busStops.filter {
                $0.name.contains(query) || $0.kana.contains(query)
            }
        }
    }
}
