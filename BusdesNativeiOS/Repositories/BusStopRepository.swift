import Foundation

protocol BusStopRepositoryProtocol {
    func getBusStops() throws -> [BusStopModel]
}

class LocalBusStopRepository: BusStopRepositoryProtocol {
    func getBusStops() throws -> [BusStopModel] {
        guard let url = Bundle.main.url(forResource: "bus_stops", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "BusStopRepo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load bus_stops.json"])
        }
        do {
            return try JSONDecoder().decode([BusStopModel].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
