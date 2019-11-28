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
        
        create()
        
        try! writingFile = FileHandle(forWritingTo: full)
    }
    
    func create() {
        if fileManager.fileExists(atPath: full.path) {
            return
        }
        
        let _: Bool = fileManager.createFile(atPath: full.path, contents: Data(count: Int(file.size!)), attributes: nil)
    }
    
    func write(seek: Int64, unUrl: Any) -> Int64 {
        var url: URL!
        if let tmpFileName = unUrl as? String {
            url = self.tmpPath.appendingPathComponent(tmpFileName)
        } else {
            url = unUrl as? URL
        }
        
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
