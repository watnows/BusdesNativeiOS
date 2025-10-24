import SwiftUI
import SwiftData

@main
struct BusdesNativeiOSApp: App {

    let container = {
        do {
            return try ModelContainer(for: Route.self)
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }()

    @StateObject private var userModel: UserService
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var adService = AdService.shared

    init() {
        let modelContext = container.mainContext
        let um = UserService(modelContext: modelContext)
        _userModel = StateObject(wrappedValue: um)
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(userModel: um))
        
        AdService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environmentObject(userModel)
                .environmentObject(homeViewModel)
                .environmentObject(adService)
        }
        .modelContainer(container)
    }
}
