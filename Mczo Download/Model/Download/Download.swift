//
//  Download.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/11.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

enum DownloadError: Error {
    case notNetwork
}

protocol DownloadProtocol {
    var file: File { get set }
    
    func start()
    func pause()
}

struct File: FileProtocol {
    var url: URL
    var name: String
    var mime: String?
    var size: Int64?
    var threads: [[Int64]]?
    var createdAt: Date
    var ext: String?
}

protocol FileProtocol {
    var url: URL { get set }
    var name: String { get set }
    var mime: String? { get set }
    var size: Int64? { get set }
    var threads: [[Int64]]? { get set }
    var createdAt: Date { get set }
    var ext: String? { get set }
}
