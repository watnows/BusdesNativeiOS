//
//  Routes+CoreDataProperties.swift
//  BusdesNativeiOS
//
//  Created by 黒川龍之介 on 2024/06/22.
//
//

import Foundation
import CoreData


extension Routes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Routes> {
        return NSFetchRequest<Routes>(entityName: "Routes")
    }

    @NSManaged public var to: String?
    @NSManaged public var from: String?

}

extension Routes : Identifiable {

}
