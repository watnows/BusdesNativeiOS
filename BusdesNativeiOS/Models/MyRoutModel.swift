import Foundation

struct MyRoute: Codable {
    var from: String
    var to: String
}

extension MyRoute {
    static let demo = MyRoute(from: "立命館大学", to: "南草津駅")
}
