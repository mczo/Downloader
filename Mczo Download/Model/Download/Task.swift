//
//  Task.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

protocol DLCallBackProtocol: class {
    func head(objects: [String: Any]) -> Void
    func downloading() -> Void
    func pause(objects: [String: Any]) -> Void
    func complete(objects: [String: Any]) -> Void
    func failure(objects: [String: Any]) -> Void
}

protocol DLStatusProtocol: class {
    var status: DLStatus { get set }
}

class DownloadTask {
    fileprivate lazy var session: URLSession = URLSession.shared
    
    var file: File!
    
    var threads: [DownloadThread]?
    var downloadFileManage: DownloadFileManage?
    
    var callback: (DLCallBackProtocol & DLStatusProtocol)?
            
    var shard: Int8!
    var title: String!
    var url: URL!
    init(url: String, title: String, shard: Int8) {
        self.shard = shard
        self.title = title
        self.url = URL(string: url)
        
        self.file = File(
            url: self.url,
            name: self.url.lastPathComponent,
            createdAt: Date()
        )
        
        self.callback = DLCallBack()
        
        DispatchQueue.global().async {
            do {
                try self.header()
                
                self.downloading()
            } catch {
                self.callback?.failure(objects: [
                    "name": self.file.name,
                    "createdAt": self.file.createdAt,
                    "url": self.file.url.absoluteString,
                    "info": "网络错误"
                ])
            }
        }
    }
    
    init(continuance file: File, shard: Int8) {
        self.shard = shard
        self.title = file.name
        self.url = file.url
        
        self.file = file
        
        self.callback = DLCallBack()
        self.callback?.status = .pause
    }
    
    deinit {
        print("wc")
    }
    
    private func getHeader() {
        let sema = DispatchSemaphore(value: 0)
        let request: URLRequest = {
            var config = URLRequest(url: self.url)
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
                        print("error code")
                        sema.signal()
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

                let fileName: String = response?.suggestedFilename ?? self.url.lastPathComponent
                let fileExt: String = URL(fileURLWithPath: fileName).pathExtension
                self.file = File(
                        url: res.url!,
                        name: self.title.isEmpty ? fileName : self.title + "." + fileExt,
                        size: size,
                        threads: threads,
                        createdAt: self.file.createdAt,
                        ext: fileExt)
                
                sema.signal()
            }.resume()
        
        sema.wait()
    }
    
    func header() throws {
        self.getHeader()
        if self.file.size == nil { throw DownloadError.notNetwork }
        
        self.downloadFileManage = DownloadFileManage(normal: self.file)
        
        self.callback?.head(objects: [
            "name": self.file.name,
            "createdAt": self.file.createdAt,
            "url": self.file.url.absoluteString,
            "size": self.file.size ?? 0,
            "ext": self.file.ext ?? "",
            "shard": Int16(self.shard!)
        ])
    }
    
    private var dlComplete: Int8 = 0
    func downloading() {
        let completeCallback: (_ index: Int) -> Void = {  // 下载完成
            index in
            
            // 完成数 +1
            self.dlComplete += 1
            
            // 下载完成线程的字节数修改
            self.file!.threads![index][0] = self.file!.threads![index][1]
            
            if self.dlComplete == self.shard {
                self.callback?.complete(objects: [
                    "name": self.file.name,
                    "createdAt": self.file.createdAt,
                    "url": self.file.url.absoluteString,
                    "size": self.file.size ?? 0,
                    "ext": self.file.ext ?? ""
                ])
                
                self.downloadFileManage?.close()
            }
        }
        
        guard let threadSeeds = self.file.threads else { return }
        
        self.threads = Array()
        for index in 0..<threadSeeds.count {
            if threadSeeds[index].first == threadSeeds[index].last {
                self.dlComplete += 1
                continue
            }
            
            let downloadThread = DownloadThread(
                downloadFileManage: downloadFileManage!,
                file: self.file,
                index: index)
            
            downloadThread.downloading(callback: completeCallback)
            self.threads?.append(downloadThread)
        }
        
        self.callback?.downloading()
    }
    
    func continuance() {
        self.downloadFileManage = DownloadFileManage(continuance: self.file)
        
        self.dlComplete = 0
        self.downloading()
    }
    
    func pause() {
        guard let threads = self.threads else { return }
        
        var count: Int8 = 0
        let pauseCallback: (_ index: Int, _ breakpoint: Int64) -> Void = {
            index, breakpoint in
            
            self.file!.threads?[index][0] = breakpoint
            
            count += 1
            if count == self.shard - self.dlComplete {
                let threadsData: Data = try! NSKeyedArchiver.archivedData(withRootObject: self.file!.threads ?? Array(), requiringSecureCoding: true)
                
                if  let dl: Int64 = self.threads?.reduce(0, { $0 + ($1.totalBytesWritten ?? 0) }),
                    let size: Int64 = self.file.size {
                    self.file.proportion = Float(dl) / Float(size)
                    
                    self.threads = nil
                } else { self.file.proportion = 0 }
                
                self.callback?.pause(objects: [
                    "name": self.file.name,
                    "threads": threadsData,
                    "proportion": self.file.proportion ?? 0
                ])
                
                self.downloadFileManage?.close()
            }
        }
        
        for thread in threads {
            thread.pause(callback: pauseCallback)
        }
    }
    
    func cancel() {
        if let threads = self.threads {
            for thread in threads {
                thread.cancel()
            }
        }
        
        self.callback?.failure(objects: [
            "name": self.file.name,
            "createdAt": self.file.createdAt,
            "url": self.file.url.absoluteString,
            "info": "停止下载"
        ])
        
        self.downloadFileManage?.close()
        self.downloadFileManage?.delete()
    }
}
