import SwiftUI

@main
struct BusdesNativeiOSApp: App {
    var body: some Scene {
        WindowGroup {
            BaseView(
                homeViewModel: HomeViewModel(
                    bus: ApproachInfo(
                        approachInfos: [NextBusModel.demo]
                    ),
                    myRouteList:
                        [MyRoute.demo]
                ),
                timeTableViewModel: TimeTableViewModel()
            )
        }
    }
}
