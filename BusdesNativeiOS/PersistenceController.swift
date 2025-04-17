// Persistence.swift (Xcodeテンプレートの例)
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // プレビュー用のダミーデータ作成 (必要であれば)
        for i in 0..<2 {
            let newItem = SavedRoute(context: viewContext) // エンティティ名を合わせる
            newItem.from = "デモ出発地 \(i)"
            newItem.to = "デモ目的地 \(i)"
            newItem.createdAt = Date()
            newItem.id = UUID()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // データモデルファイル名（.xcdatamodeld）を正しく指定
        container = NSPersistentContainer(name: "BusdesNativeiOS") // ← データモデル名に合わせる
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}