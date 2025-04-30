import SwiftUI

@main
struct BusdesNativeiOSApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userModel: UserSession
    @StateObject private var homeViewModel: HomeViewModel

    init() {
        let um = UserSession()
        _userModel = StateObject(wrappedValue: um)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(userModel: um))
    }

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userModel)
                .environmentObject(homeViewModel)
        }
    }
}
