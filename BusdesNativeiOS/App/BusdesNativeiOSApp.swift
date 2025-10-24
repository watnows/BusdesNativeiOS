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

    init() {
        // 広告サービスの初期化（シングルトン）
        AdService.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            BaseView()
        }
        .modelContainer(container)
    }
}
