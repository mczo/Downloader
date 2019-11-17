//
//  Config.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/12.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataDownload: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var url: String
}

protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortDescriptors: NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        return [sortDescriptors]
    }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return entity().name!
    }
}
