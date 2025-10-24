import Foundation
import SwiftData

@Model
final class NextBus {
    var id: UUID = UUID()
    var moreMin: String
    var realArrivalTime: String
    var direction: String
    var via: String
    var scheduledTime: String
    var delay: String
    var busStop: String
    var requiredTime: Int
    
    enum CodingKeys: String, CodingKey {
        case moreMin
        case realArrivalTime
        case direction
        case via
        case scheduledTime
        case delay
        case busStop
        case requiredTime
    }
    
    init(id: UUID, moreMin: String, realArrivalTime: String, direction: String, via: String, scheduledTime: String, delay: String, busStop: String, requiredTime: Int) {
        self.id = id
        self.moreMin = moreMin
        self.realArrivalTime = realArrivalTime
        self.direction = direction
        self.via = via
        self.scheduledTime = scheduledTime
        self.delay = delay
        self.busStop = busStop
        self.requiredTime = requiredTime
    }
}
