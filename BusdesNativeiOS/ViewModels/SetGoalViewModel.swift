import Combine
import SwiftUI

@MainActor
class SetGoalViewModel: ObservableObject {
    let from: BusStopModel

    init(from: BusStopModel) {
        self.from = from
    }

    func setRoute(to : String, userModel: UserService) {
        userModel.addRoute(from: from.name, to: to)
    }
}
