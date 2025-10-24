import SwiftUI
import SwiftData

@main
struct BusdesNativeiOSApp: App {

    // SwiftDataコンテナ（スキーマ変更対応）
    let container = {
        do {
            let schema = Schema([Route.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // スキーマ変更エラーの場合、データを削除して再作成
            #if DEBUG
            print("⚠️ SwiftData migration error: \(error)")
            print("🔄 Clearing old data and creating new container...")
            #endif

            // 既存のデータベースファイルを削除
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)

            // 新しいコンテナを作成
            do {
                let schema = Schema([Route.self])
                let modelConfiguration = ModelConfiguration(schema: schema)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Failed to configure SwiftData container after cleanup: \(error)")
            }
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
