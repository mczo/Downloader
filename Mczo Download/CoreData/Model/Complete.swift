//
//  Complete.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/22.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData
import Combine

public class ModelComplete: CoreDataDownload, Managed, Identifiable {
    @NSManaged public var size: Int64
    @NSManaged public var ext: String
}
