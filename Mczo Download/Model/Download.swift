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
    let url: URL
    let name: String
    let mime: String
    let size: Int64
    var threads: [[Int64]]
    let save: URL
//    let ext: String
    var full: URL {
        return save.appendingPathComponent(name)
    }
}

protocol FileProtocol {
    var url: URL { get }
    var name: String { get }
    var mime: String { get }
    var size: Int64 { get }
    var threads: [[Int64]] { get set }
    var save: URL { get }
}

class DownloadTask {
    fileprivate lazy var saveDir: URL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    fileprivate lazy var session: URLSession = URLSession.shared
    
    var file: File?
    
    var threads: [DownloadThread] = Array()
    private var downloadFileManage: DownloadFileManage?
    
    var status: DLStatus?
    
    var shard: Int8!
    var title: String!
    var url: String!
    init(url urlString: String, title: String, shard: Int8) {
        self.shard = shard
        self.title = title
        self.url = urlString
    }
    
    init(file: File) {
        
    }
    
    private func getHeader(urlString: String) {
        let sema = DispatchSemaphore(value: 0)
        
        let request: URLRequest = {
            var config = URLRequest(url: URL(string: urlString)!)
            config.httpMethod = "HEAD"
            
            return config
        }()
        
        session
            .dataTask(with: request) {
                data, response, error in
                
                if let error = error {
                    print(error)
                    sema.signal()
                    return
                }
                
                guard case let res as HTTPURLResponse = response,
                    200..<300 ~= res.statusCode else {
                        return
                    }
                
                var threads: [[Int64]] = Array()
                let size: Int64 = Int64(res.value(forHTTPHeaderField: "Content-Length")!)!
                let blockSize: Int64 = size / Int64(self.shard)
                for threadId in 0..<self.shard {
                    var startSeed: Int64 = Int64(threadId) * blockSize,
                        endSeed: Int64 = Int64(threadId + 1) * blockSize - 1
                    if threadId == self.shard - 1 {
                        endSeed = size - 1
                    }
                    threads.append([startSeed, endSeed])
                }
                
                
                if self.title.isEmpty {
                    self.title = response?.suggestedFilename
                }
                    
                self.file = File(
                        url: res.url!,
                        name: self.title,
                        mime: res.value(forHTTPHeaderField: "Content-Type")!,
                        size: size,
                        threads: threads,
                        save: self.saveDir
                )
                
                sema.signal()
            }
            .resume()
        
        sema.wait()
    }
    
    func header() throws {
        getHeader(urlString: url)
        guard let exFile = file else { throw DownloadError.notNetwork }
        
        status = .wait
        downloadFileManage = DownloadFileManage(file: exFile)
        
        for index in 0..<exFile.threads.count {
            threads.append(
                DownloadThread(downloadFileManage: downloadFileManage!,
                file: exFile,
                index: index) )
        }
    }
    
    func start() {
        status = .downloading
        
        for thread in threads {
            thread.start()
        }
    }
    
    func pause() {
        status = .pause
    }
}

class DownloadThread: NSObject, DownloadProtocol {
    private let fileManager = FileManager.default
    private let downloadFileManage: DownloadFileManage
    lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    var request: URLRequest
    var task: URLSessionDownloadTask?
    var file: File
    let seeks: [Int64]
    
    var bytesWritten: Int64?
    var totalBytesWritten: Int64?
    var totalBytesExpectedToWrite: Int64?
    var process: Float {
        get {
            guard let current = totalBytesWritten else { return 0 }
            guard let total = totalBytesExpectedToWrite else { return 0 }
            return Float(current) / Float(total) * 100
        }
    }
    
    init(downloadFileManage: DownloadFileManage, file: File, index: Int) {
        self.file = file
        self.downloadFileManage = downloadFileManage
        
        seeks = file.threads[index]
        self.request = URLRequest(url: file.url)
        request.httpMethod = "GET"
        request.addValue("bytes=\(seeks.first!)-\(seeks.last!)", forHTTPHeaderField: "Range")
        super.init()
        
        task = session.downloadTask(with: request)
    }
        
    func start() {
        task?.resume()
    }
    
    func pause() {
        
    }
}

extension DownloadThread: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileData = fileManager.contents(atPath: location.path)
        downloadFileManage.write(seek: seeks.first!, data: fileData!)
        print(location.path, file.size)
        
        do {
            try fileManager.removeItem(at: location)
        } catch {
            print("文件删除失败")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.task {
            self.bytesWritten = bytesWritten
            self.totalBytesWritten = totalBytesWritten
            self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        }
    }
}



class DownloadFileManage {
    private lazy var fileManager: FileManager = FileManager.default
    private var writingFile: FileHandle?
    var file: File
    
    init(file: File) {
        self.file = file
        create()
        
        try! writingFile = FileHandle(forWritingTo: file.full)
    }
    
    func create() {
        if fileManager.fileExists(atPath: file.full.path) {
            return
        }
        
        let _: Bool = fileManager.createFile(atPath: file.full.path, contents: Data(count: Int(file.size)), attributes: nil)
    }
    
    func write(seek: Int64, data: Data) {
        writingFile?.seek(toFileOffset: UInt64(seek))
        writingFile?.write(data)
    }
    
    func close() {
        writingFile?.closeFile()
    }
}
