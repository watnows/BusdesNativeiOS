import Combine
import Foundation

@MainActor
class AddLineViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var filteredData: [BusStopModel] = []
    private var busStops: [BusStopModel] = []
    private let busStopRepository: BusStopRepositoryProtocol
    
    init(busStopRepository: BusStopRepositoryProtocol = LocalBusStopRepository()) {
        self.busStopRepository = busStopRepository
        loadBusStops()
        self.filteredData = busStops
    }
    
    private func loadBusStops() {
        do {
            busStops = try busStopRepository.getBusStops()
            filteredData = busStops
        } catch {
            busStops = []
            filteredData = []
        }
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
