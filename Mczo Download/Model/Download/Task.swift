//
//  Task.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

@objc protocol DLCallBackProtocol: class {
    @objc optional func downloading() -> Void
    @objc optional func pause() -> Void
    @objc optional func complete(objects: [String: Any]) -> Void
    @objc optional func failure() -> Void
}

protocol DLStatusProtocol: class {
    var status: DLStatus { get set }
}

class DownloadTask {
    fileprivate lazy var session: URLSession = URLSession.shared
    
    var file: File!
    
    var threads: [DownloadThread] = Array()
    private var downloadFileManage: DownloadFileManage?
    
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
            createdAt: Date())
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

                if self.title.isEmpty {
                    self.title = response?.suggestedFilename
                }

                self.file = File(
                        url: res.url!,
                        name: self.title,
                        mime: res.value(forHTTPHeaderField: "Content-Type")!,
                        size: size,
                        threads: threads,
                        createdAt: self.file.createdAt,
                        ext: URL(fileURLWithPath: self.title).pathExtension
                )
                
                sema.signal()
            }.resume()
        
        sema.wait()
    }
    
    func header() throws {
        getHeader()
        if self.file.size == nil { throw DownloadError.notNetwork }

        downloadFileManage = DownloadFileManage(file: self.file)

        for index in 0..<self.file.threads!.count {
            threads.append(DownloadThread(downloadFileManage: downloadFileManage!,
                                          file: self.file,
                                          index: index))
        }
    }
    
    private var completeTotal: Int8 = 0
    func downloading() {
        let completeCallback: (() -> Void) = {
            self.completeTotal += 1
            if self.completeTotal == self.shard {
                self.callback?.complete?(objects: [
                    "name": self.file.name,
                    "createdAt": self.file.createdAt,
                    "url": self.file.url.absoluteString,
                    "size": self.file.size ?? 0,
                    "ext": self.file.ext ?? ""
                ])
            }
        }
        
        for thread in threads {
            thread.downloading(callback: completeCallback)
        }
        
        self.callback?.downloading?()
    }
    
    func pause() {
        for thread in threads {
            thread.pause()
        }
        
        self.callback?.pause?()
    }
}
