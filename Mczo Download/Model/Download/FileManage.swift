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
    let tmpPath: URL
    
    init(file: File) {
        self.file = file
        self.full = try! fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(file.name)
        self.tmpPath = fileManager.temporaryDirectory
    }
    
    convenience init(normal file: File) {
        self.init(file: file)
        
        create()
        try! writingFile = FileHandle(forWritingTo: full)
    }
    
    convenience init(continuance file: File) {
        self.init(file: file)
        
        try! writingFile = FileHandle(forUpdating: full)
    }
    
    func create() {
        if fileManager.fileExists(atPath: full.path) {
            return
        }
        
        let _: Bool = fileManager.createFile(atPath: full.path, contents: Data(count: Int(file.size!)), attributes: nil)
    }
    
    func write(seek: Int64, url: URL) -> Int64 {
        guard let fileData = self.fileManager.contents(atPath: url.path) else { return 0 }

        writingFile?.seek(toFileOffset: UInt64(seek))
        writingFile?.write(fileData)

        do {
            try self.fileManager.removeItem(at: url)
        } catch {
            print("文件删除失败")
        }
        
        return Int64(fileData.count)
    }
    
    func close() {
        writingFile?.closeFile()
    }
    
    func delete() {
        do {
            try self.fileManager.removeItem(at: self.full)
        } catch {
            print("文件删除失败")
        }
    }
    
    func check(size: Int64) -> URL {
        var currentUrl: URL!
        let enumerator = self.fileManager.enumerator(
            at: self.tmpPath,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles],
            errorHandler: {(url, error) -> Bool in
                return true
        })
        
        while let element = enumerator?.nextObject() as? URL {
            let attr = try! self.fileManager.attributesOfItem(atPath: element.path)
            let fileSize: Int64 = attr[FileAttributeKey.size] as! Int64
            
            if size == fileSize {
                currentUrl = element
                break
            }
        }
        
        return currentUrl
    }
}
