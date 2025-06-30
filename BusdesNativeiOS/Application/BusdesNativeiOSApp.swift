import SwiftUI

@main
struct BusdesNativeiOSApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userModel: UserService
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var adService = AdService.shared

    init() {
        let um = UserService()
        _userModel = StateObject(wrappedValue: um)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(userModel: um))
        
        AdService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userModel)
                .environmentObject(homeViewModel)
                .environmentObject(adService)
        }
    }
}
