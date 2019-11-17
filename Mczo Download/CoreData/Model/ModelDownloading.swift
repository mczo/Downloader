//
//  ModelDownloading.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/16.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData

public class ModelDownloading: CoreDataDownload, Managed {
    @NSManaged public var mime: String
    @NSManaged public var size: Int64
    //    @NSManaged fileprivate(set) var threads: [[Int]]
}
