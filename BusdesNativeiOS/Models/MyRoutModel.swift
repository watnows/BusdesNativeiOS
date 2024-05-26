import Foundation

struct MyRoute: Codable {
    var fr: String
    var to: String
}

extension MyRoute {
    static let demo = MyRoute(fr: "立命館大学", to: "南草津駅")
}
