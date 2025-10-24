import SwiftData

@Model
final class Routes {
    var to: String
    var from: String
    
    init(to: String, from: String) {
        self.to = to
        self.from = from
    }
}
