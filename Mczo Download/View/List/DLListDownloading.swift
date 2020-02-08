//
//  DLListDownloading.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/7.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI
import Combine

struct DLListDownloading: View {
    @EnvironmentObject var downloadingManage: DownloadingManage
    @State private var waitSpin: Bool = false
    
    var body: some View {
        TemplateList(
            downloadingManage.list,
            cover: { item in
                ZStack {
                    if item.status == DLStatus.wait {
                        ArcShape(pct: 0.85)
                            .foregroundColor(Color("asset"))
                            .rotationEffect(.degrees(self.waitSpin ? 360: 0))
                            .animation(Animation.linear(duration: 1.1).repeatForever(autoreverses: false))
                            .onAppear() {
                                self.waitSpin.toggle()
                            }
                    } else {
                        Circle()
                            .fill(Color("asset"))
                            .padding(.all, 4)

                        ArcShape(pct: item.process)
                            .foregroundColor(Color("asset"))
                            .frame(width: 34, height: 34)

                        Group {
                            if item.status == DLStatus.downloading {
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            } else if item.status == DLStatus.pause {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if item.status == DLStatus.downloading {
                        item.pause()
                    } else if item.status == DLStatus.pause {
                        item.continuance()
                    }
                }
            }, title: { item in
                Text(item.file.name)
            }, meta: { item in
                Text(item.speed.btySize)

                Spacer()

                Text(item.time.timeDec)
            }, actions: TemplateListActionRandomAccess([
                (
                    key: "ellipsis",
                    value: { index in
                        print(index)
                    }
                ),
                (
                    key: "multiply",
                    value: { index in
                        print(index)
                    }
                )
            ]) )
    }
}


class DLCallBack: DLCallBackProtocol, DLStatusProtocol {
    var status: DLStatus = .wait
    
    // 获得 CoreData 实例
    let downloadingModelOperat: ModelOperat = ModelOperat<ModelDownloading>()
    let completeModelOperat: ModelOperat = ModelOperat<ModelComplete>()
    let failureModelOperat: ModelOperat = ModelOperat<ModelFailure>()
    
    func head(objects: [String: Any]) {
        self.downloadingModelOperat.insert(objects: objects)
    }
    
    func downloading() {
        self.status = .downloading
    }
    
    func pause(objects: [String: Any]) {
        self.status = .pause
        
        self.downloadingModelOperat.update(name: objects["name"] as! String, objects: objects)
    }
    
    func complete(objects: [String: Any]) {
        self.status = .complete
        
        self.completeModelOperat.insert(objects: objects)
        
        self.downloadingModelOperat.delete(name: objects["name"] as! String)
    }
    
    func failure(objects: [String: Any]) {
        self.status = .failure
        
        self.downloadingModelOperat.delete(name: objects["name"] as! String)
        self.failureModelOperat.insert(objects: objects)
    }
}

final class DownloadingManage: ObservableObject {
    @Published var list: [DLTaskGenre] = []
    
    private var cancellable: AnyCancellable?
    
    init() {
        let res = ModelOperat<ModelDownloading>().fetch()
        for item in res {
            let unarchiveObject = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(item.threads)
            let threadsObject = unarchiveObject as! [[Int64]]
            let file: File = File(
                url: URL(string: item.url)!,
                name: item.name,
                size: item.size,
                threads: threadsObject,
                createdAt: item.createdAt,
                ext: item.ext,
                proportion: item.proportion)
            
            self.list.append( DLTaskGenre(continuance: file, shard: Int8(item.shard)) )
        }
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .sink() {
            _ in
            
            let result = self.list.drop {
                item -> Bool in
                
                return item.status == .complete || item.status == .failure
            }
            
            self.list = Array(result)
        }
    }
}

class DLTaskGenre: DownloadTask, Identifiable {
    var id: UUID = UUID()
    
    private var prevTotalBytesWritten: [Int64] = [0, 0]
    
    var status: DLStatus {
        get {
            self.callback!.status
        }
    }
}

extension DLTaskGenre {
    var process: CGFloat {
        get {
            guard   let threads: [DownloadThread] = self.threads,
                    let size: Int64 = self.file.size else { return CGFloat(self.file.proportion ?? 0) }
            
            let dl: Int64 = threads.reduce(0) { $0 + ($1.totalBytesWritten ?? 0) }
            let proportion: Float = Float(dl) / Float(size) + (self.file.proportion ?? 0)

            return CGFloat(proportion)
        }
    }
    
    var speed: Int64 {
        get {
            guard let threads = self.threads else {
                return -1
            }
            
            let currentTotalBytesWritten: Int64 = threads.reduce(0) {
                all, current in

                guard let totalBytesWritten = current.totalBytesWritten else { return 0 }
                return all + totalBytesWritten
            }
            
            let currentSpeed: Int64 = currentTotalBytesWritten - self.prevTotalBytesWritten[0]
            self.prevTotalBytesWritten[0] = currentTotalBytesWritten
            return currentSpeed
        }
    }

    var time: Int64 {
        get {
            guard   let size = self.file.size,
                    let threads = self.threads else {
                        return -1
                    }
            
            let currentTotalBytesWritten: Int64 = threads.reduce(0) {
                all, current in

                guard let totalBytesWritten = current.totalBytesWritten else { return 0 }
                return all + totalBytesWritten
            }
            let currentSpeed: Int64 = currentTotalBytesWritten - self.prevTotalBytesWritten[1]
            self.prevTotalBytesWritten[1] = currentTotalBytesWritten
            
            if currentSpeed == 0 { return -1 }
            let time: Int64 = (size - currentTotalBytesWritten) / currentSpeed
            return time
        }
    }
}

fileprivate struct ArcShape: Shape {
    let pct: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()

        p.addArc(center: CGPoint(x: rect.width / 2, y:rect.height / 2),
                 radius: rect.height / 2,
                 startAngle: .degrees(-90),
                 endAngle: .degrees(360 * Double(pct) - 90), clockwise: false)

        return p.strokedPath(.init(lineWidth: 4, lineCap: .round))
    }
}
