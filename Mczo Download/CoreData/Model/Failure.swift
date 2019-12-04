//
//  Failure.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/12/3.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import CoreData
import Combine

public class ModelFailure: CoreDataDownload, Managed, Identifiable {
    @NSManaged public var info: String
}
