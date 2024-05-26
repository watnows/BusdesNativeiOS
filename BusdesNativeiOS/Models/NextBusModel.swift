struct NextBusModel: Codable {
    let moreMin: String
    var realArrivalTime: String
    let direction: String
    let via: String
    let scheduledTime: String
    let delay: String
    let busStop: String
    let requiredTime: Int
}

struct ApproachInfo: Codable {
    var approachInfos: [NextBusModel]
}

extension NextBusModel {
    static let demo = NextBusModel(moreMin: "約n分後に到着", realArrivalTime: "16:56", direction: "立命館大学行き", via: "50号系統", scheduledTime: "16:56", delay: "定時運行", busStop: "1", requiredTime: 42)
}
