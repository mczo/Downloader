//
//  Downloading.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/16.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData

public class ModelDownloading: CoreDataDownload, Managed {
    @NSManaged public var ext: String
    @NSManaged public var size: Int64
    @NSManaged public var threads: Data
    @NSManaged public var proportion: Float
    @NSManaged public var shard: Int16
}
