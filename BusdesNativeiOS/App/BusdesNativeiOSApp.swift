import SwiftUI
import SwiftData

@main
struct BusdesNativeiOSApp: App {

    // SwiftDataコンテナ
    let container = {
        do {
            return try ModelContainer(for: Route.self)
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }()

    // 広告サービス（@Observable対応）
    @State private var adService = AdService.shared

    init() {
        // 広告サービスの初期化
        AdService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environment(adService)
        }
        .modelContainer(container)
    }
}
