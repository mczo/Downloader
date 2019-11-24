//
//  FileManage.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

class DownloadFileManage {
    private var fileManager: FileManager = FileManager.default
    private var writingFile: FileHandle?
    var file: File
    let full: URL
    
    init(file: File) {
        self.file = file
        self.full = try! fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(file.name)
        
        create()
        
        try! writingFile = FileHandle(forWritingTo: full)
    }
    
    func create() {
        if fileManager.fileExists(atPath: full.path) {
            return
        }
        
        let _: Bool = fileManager.createFile(atPath: full.path, contents: Data(count: Int(file.size!)), attributes: nil)
    }
    
    func write(seek: Int64, data: Data) {
        writingFile?.seek(toFileOffset: UInt64(seek))
        writingFile?.write(data)
    }
    
    func close() {
        writingFile?.closeFile()
    }
}
