import Foundation
import CoreData

@objc(Routes)
public class Routes: NSManagedObject, Identifiable {
}

extension Routes {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Routes> {
        return NSFetchRequest<Routes>(entityName: "Routes")
    }
    @NSManaged public var to: String?
    @NSManaged public var from: String?
}
