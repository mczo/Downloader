//
//  Thread.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

class DownloadThread: NSObject {
    private let fileManager = FileManager.default
    private let downloadFileManage: DownloadFileManage
    lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    var request: URLRequest
    var task: URLSessionDownloadTask?
    var file: File
    let index: Int
    
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
    
    var callback: (() -> Void)!
    
    init(downloadFileManage: DownloadFileManage, file: File, index: Int) {
        self.file = file
        self.index = index
        self.downloadFileManage = downloadFileManage
        
        self.request = URLRequest(url: file.url)
        request.httpMethod = "GET"
        request.addValue("bytes=\(self.file.threads![index].first!)-\(self.file.threads![index].last!)", forHTTPHeaderField: "Range")
        super.init()
        
        self.task = session.downloadTask(with: request)
    }
        
    func downloading(callback: @escaping () -> Void) {
        self.callback = callback
        
        
        
        self.task?.resume()
    }
    
    func pause() {
        self.task?.cancel()
    }
}

extension DownloadThread: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileData = fileManager.contents(atPath: location.path)
        downloadFileManage.write(seek: self.file.threads![index].first!, data: fileData!)
        print(location.path, fileData!.count)
        
        self.callback()
        
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil { return }
        
//        self.file.threads![index].first += task.countOfBytesReceived
        print(task.countOfBytesReceived)
    }
}
