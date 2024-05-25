import Combine
import Foundation

class AddLineCellViewModel: ObservableObject {
    @Published var busStopName: String
    @Published var busStopKana: String

    init(busStopName: String, busStopKana: String) {
        self.busStopName = busStopName
        self.busStopKana = busStopKana
    }
}
