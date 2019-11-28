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
    @ObservedObject var downloadingManage: DownloadingManage
    @State private var spin: Bool = false
    
    private func listItem(item: DLTaskGenre) -> some View {
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
                                Image(systemName: "stop.fill")
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
                    item.downloading()
                }
            }
            
            NavigationLink(destination: Text("a")) {
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
        }
    }
    
    var body: some View {
        ForEach(downloadingManage.list) {
            item in
        
            self.listItem(item: item)
        }
    }
}


class DLCallBack: DLCallBackProtocol, DLStatusProtocol {
    var status: DLStatus = .wait
    
    let modelOperat: ModelOperat = ModelOperat<ModelComplete>()
    
    func downloading() -> Void {
        self.status = .downloading
    }
    
    func pause() -> Void {
        self.status = .pause
    }
    
    func complete(objects: [String: Any]) -> Void {
        self.status = .complete
        
        modelOperat.insert(objects: objects)
    }
}

class DownloadingManage: ObservableObject {
    @Published var list: [DLTaskGenre] = []
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .sink() {
            _ in
                        
            self.list = self.list
        }
    }
}

class DLTaskGenre: DownloadTask, Identifiable {
    var id: UUID = UUID()
    
    private var prevTotalBytesWritten: Int64 = 0
    
    var status: DLStatus {
        get {
            self.callback!.status
        }
    }
    
    override init(url: String, title: String, shard: Int8) {
        super.init(url: url, title: title, shard: shard)
        self.callback = DLCallBack()
        
        do {
            try header()
            downloading()
        } catch {
            self.callback?.failure?()
        }

    }
}

extension DLTaskGenre {
    var process: CGFloat {
        get {
            let total: Float = threads.reduce(0) { $0 + $1.process }
            let proportion: Float = total / Float(threads.count)

            return CGFloat(proportion * 3.6 - 90)
        }
    }
    
    var speed: Int64 {
        get {
            let currentTotalBytesWritten: Int64 = threads.reduce(0) {
                all, current in

                guard let totalBytesWritten = current.totalBytesWritten else { return 0 }
                return all + totalBytesWritten
            }
            
            let currentSpeed: Int64 = currentTotalBytesWritten - prevTotalBytesWritten
            prevTotalBytesWritten = currentTotalBytesWritten
            return currentSpeed
        }
    }

    var time: Int64 {
        get {
            var totalTime: Int64 = 0
            for thread in threads {
                guard let totalBytesExpectedToWrite = thread.totalBytesExpectedToWrite else { break }
                guard let totalBytesWritten = thread.totalBytesWritten else { break }
                guard let bytesWritten = thread.bytesWritten else { break }
                
                totalTime += (totalBytesExpectedToWrite - totalBytesWritten) / bytesWritten
            }

            return totalTime
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
