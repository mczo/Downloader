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
    @EnvironmentObject private var globalSetting: GlobalSettings
    @State private var spin: Bool = false
    
    @State private var DLAddPresented: Bool = false
    
    private func listItem(item: DLTaskGenre) -> some View {
        NavigationLink(destination: DLListInfo()) {
            HStack {
                Group {
                    if item.status == DLStatus.wait {
                        Circle()
                            .fill(Color.gray)
                            .rotationEffect(.degrees(self.spin ? 360: 0))
                            .animation(Animation.linear(duration: 1.1).repeatForever(autoreverses: false))
                            .onAppear() {
                                self.spin.toggle()
                            }
                    }
                    else {
                        ZStack {
                            ProgressButtonCircle(endAngleRadians: item.process)
                                .fill(Color.blue)

                            Group {
                                if item.status == DLStatus.downloading {
                                    Image(systemName: "pause.fill")
                                } else if item.status == DLStatus.pause {
                                    Image(systemName: "play.fill")
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .frame(width: 45, height: 45)
                .onTapGesture {
                    if item.status == DLStatus.downloading {
                        item.pause()
                    } else if item.status == DLStatus.pause {
                        item.continuance()
                    }
                }
            
                VStack {
                    HStack {
                        Text("\(item.file.name)")

                        Spacer()
                    }
                    .modifier(DLCompositionTitle())

                    HStack {
                        Text(item.speed.btySize)

                        Spacer()

                        Text(item.time.timeDec)
                    }
                    .modifier(DLCompositionDescription())
                }
            }
            .contextMenu {
                if item.status == DLStatus.downloading {
                    Button(action: {
                        item.pause()
                    }) {
                        Text("暂停")
                        Image(systemName: "pause.fill")
                    }
                }
                
                if item.status == DLStatus.pause {
                    Button(action: {
                        item.continuance()
                    }) {
                        Text("继续")
                        Image(systemName: "play.fill")
                    }
                }
                
                Button(action: {
                    item.cancel()
                }) {
                    Text("取消")
                    Image(systemName: "stop.fill")
                }
                
                Button(action: {
                    UIPasteboard.general.string = item.url.absoluteString
                }) {
                    Text("复制链接")
                    Image(systemName: "link")
                }
            }
        }
        
    }
    
    var body: some View {
        List {
            ForEach(downloadingManage.list, id: \.id) {
                item in
            
                self.listItem(item: item)
            }
        }
        .navigationBarTitle(DLStatus.downloading.title)
        .navigationBarItems(
            trailing: Button(action: {
                self.DLAddPresented.toggle()
            }) {
                Image(systemName: "plus")
            }
        )
        .sheet(
            isPresented: self.$DLAddPresented,
            content: {
                DLAdd(downloadingManage: self.downloadingManage, globalSetting: self.globalSetting, DLAddPresented: self.$DLAddPresented)
            }
        )

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
                let size: Int64 = self.file.size else { return CGFloat((self.file.proportion ?? 0) * 360 - 90) }
            
            let dl: Int64 = threads.reduce(0) { $0 + ($1.totalBytesWritten ?? 0) }
            let proportion: Float = Float(dl) / Float(size) + (self.file.proportion ?? 0)

            return CGFloat(proportion * 360 - 90)
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

fileprivate struct Circle: Shape, Animatable {
    var lineWidth: CGFloat = 2
    var startAngleRadians: CGFloat = -CGFloat.pi / 2
    var endAngleRadians: CGFloat = 10 * CGFloat.pi

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let radius = min(rect.width / 2, rect.height / 2) - (lineWidth * 4)
        p.addArc(center: CGPoint(x: rect.width/2, y: rect.height/2),
                 radius: radius,
                 startAngle: Angle(degrees: Double(startAngleRadians)),
                 endAngle: Angle(degrees: Double(endAngleRadians)),
                 clockwise: true)
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        return p.strokedPath(style)
    }
}

fileprivate struct ProgressButtonCircle: Shape {
    var lineWidth: CGFloat = 2
    var startAngleRadians: CGFloat = -90
    var endAngleRadians: CGFloat = -90
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let radius = min(rect.width / 2, rect.height / 2) - (lineWidth * 4)
        p.addArc(center: CGPoint(x: rect.width/2, y: rect.height/2),
                 radius: radius,
                 startAngle: Angle(degrees: Double(startAngleRadians)),
                 endAngle: Angle(degrees: Double(endAngleRadians)),
                 clockwise: false)
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        return p.strokedPath(style)
    }
}
