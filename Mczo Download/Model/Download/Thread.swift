//
//  Thread.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation

class DownloadThread: NSObject {
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
    
    var completeCallback: (() -> Void)!
    var pauseCallback: ((_ index: Int, _ breakpoint: Int64) -> Void)!
    
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
        self.completeCallback = callback
        print("bytes=\(self.file.threads![index].first!)-\(self.file.threads![index].last!)")
        
        self.task?.resume()
    }
    
    let REGetTmp: NSRegularExpression = try! NSRegularExpression(pattern: "CFNetworkDownload_[^.]+.tmp", options: .caseInsensitive)
    func pause(callback: @escaping (_ index: Int, _ breakpoint: Int64) -> Void) {
        self.pauseCallback = callback
        
        self.task?.cancel() {
            resumeDataOrNil in
            
            guard let resumeData = resumeDataOrNil else { return }
            let unprocess: String = String(decoding: resumeData, as: UTF8.self)
            
            guard let matchs = self.REGetTmp.firstMatch(in: unprocess, options: .reportProgress, range: NSRange(location: 0, length: unprocess.count)) else { return }
            let tmpFileName: String = (unprocess as NSString).substring(with: matchs.range)
            
            let fileSize: Int64 = self.downloadFileManage.write(seek: self.file.threads![self.index].first!, unUrl: tmpFileName)

            self.pauseCallback(self.index, self.file.threads![self.index].first! + fileSize)
        }
    }
}

extension DownloadThread: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        _ = self.downloadFileManage.write(seek: self.file.threads![self.index].first!, unUrl: location)
        print(self.index, "complete")
        self.completeCallback()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.task {
            self.bytesWritten = bytesWritten
            self.totalBytesWritten = totalBytesWritten
            self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        }
    }
}
