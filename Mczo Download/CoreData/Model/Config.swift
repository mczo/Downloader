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
    
    static var defaultFetchRequest: NSFetchRequest<Self> {
        get {
            return NSFetchRequest<Self>(entityName: entityName)
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

struct ModelOperat<Model> where Model: CoreDataDownload & Managed {
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetch() -> [Model] {
        let fetchRequest = Model.defaultFetchRequest
        var requests: [Model] = Array()
        
        do {
            requests = try self.context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return requests
    }
    
    func insert(objects: [String: Any]) -> Void {
        let model = Model(context: self.context)
        model.setValuesForKeys(objects)
        
        do {
            try self.context.save()
        } catch {
            print("error")
        }
    }
    
    func update(name: String, objects: [String: Any]) -> Void {
        let fetchRequest = Model.defaultFetchRequest
        let predicate: NSPredicate = NSPredicate(format: "name == %@", NSString(string: name))
        fetchRequest.predicate = predicate
        
        do {
            let requests = try self.context.fetch(fetchRequest)
            if requests.count == 1 {
                let request = requests.first!
                request.setValuesForKeys(objects)
                
                try self.context.save()
            }
        } catch {
            print(error)
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
    
    func delete(name: String) {
        let fetchRequest = Model.defaultFetchRequest
        let predicate: NSPredicate = NSPredicate(format: "name == %@", NSString(string: name))
        fetchRequest.predicate = predicate
        
        do {
            let requests = try self.context.fetch(fetchRequest)
            if requests.count == 1 {
                let request = requests.first!
                self.context.delete(request)
                
                try self.context.save()
            }
        } catch {
            print(error)
        }
    }
}
