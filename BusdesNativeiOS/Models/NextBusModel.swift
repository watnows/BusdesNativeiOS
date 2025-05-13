import Foundation

struct NextBusModel: Codable, Identifiable, Hashable  {
    var id: UUID = UUID()
    let moreMin: String
    var realArrivalTime: String
    let direction: String
    let via: String
    let scheduledTime: String
    let delay: String
    let busStop: String
    let requiredTime: Int
    
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
}

struct ApproachInfo: Codable {
    var approachInfos: [NextBusModel]
}
