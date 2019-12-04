//
//  Config.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/12.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

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
        get {
            let sortDescriptors: NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            return [sortDescriptors]
        }
    }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        get {
            let request: NSFetchRequest<Self> = NSFetchRequest<Self>(entityName: entityName)
            request.sortDescriptors = defaultSortDescriptors
            return request
        }
    }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return entity().name!
    }
}

struct ModelOperat<Model> where Model: NSManagedObject {
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func insert(objects: [String: Any]) -> Void {
        let model = Model(context: self.context)

        for (key, value) in objects {
            switch value {
            case let val where val is String:
                model.setValue(value as! String, forKey: key)
                
            case let val where val is Date:
                model.setValue(value as! Date, forKey: key)
                
            case let val where val is Int64:
                model.setValue(value as! Int64, forKey: key)
                
            default:
                break
            }
        }
                
        do {
            try self.context.save()
        } catch {
            print("error")
        }
    }
    
    func delete(item: NSManagedObject) {
        self.context.delete(item)
        
        do {
            try self.context.save()
        } catch {
            print("error")
        }
    }
}
