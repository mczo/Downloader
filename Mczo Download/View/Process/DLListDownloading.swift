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
    @State private var spin: Bool = false
    
    @ObservedObject var downloadingManage: DownloadingManage
    
    var body: some View {
        ForEach(downloadingManage.list) {
            item in
        
            NavigationLink(destination: Text("a")) {
                Text("aa\((item as DLTaskGenre).process) \((item as DLTaskGenre).speed) \((item as DLTaskGenre).time)")
//                HStack {
//                    VStack {
//                        if item.status == DLStatus.wait {
//                            Circle()
//                                .fill(Color.gray)
//                                .rotationEffect(.degrees(self.spin ? 360: 0))
//                                .animation(Animation.linear(duration: 1.1).repeatForever(autoreverses: false))
//                                .onAppear() {
//                                    self.spin.toggle()
//                                }
//                        } else {
//                            ZStack {
//                                ProgressButtonCircle(endAngleRadians: item.process)
//                                    .fill(Color.blue)
//
//                                Group {
//                                    if item.status == DLStatus.downloading {
//                                        Image(systemName: "stop.fill")
//                                    } else if item.status == DLStatus.pause {
//                                        Image(systemName: "play.fill")
//                                    }
//                                }
//                                .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                    .frame(width: 45, height: 45)
//
//
//                    VStack {
//                        HStack {
//                            Text(item.file!.name)
//                                .modifier(DLCompositionTitle())
//
//                            Spacer()
//                        }
//
//                        HStack {
//                            Text(item.speed.btySize)
//
//                            Spacer()
//
//                            Text(item.time.timeDec)
//                        }
//                        .modifier(DLCompositionDescription())
//                    }
//                }
            }
        }
    }
}



class DownloadingManage: ObservableObject {
    @Published var list: [DLTaskGenre] = []
    
    init() {
        
    }
}

class DLTaskGenre: DownloadTask, Identifiable {
    var id: UUID = UUID()
    @Published var cancellable: AnyCancellable?
    
    @Published var process: CGFloat = -90
    @Published var speed: Int64 = -1
    @Published var time: Int64 = -1
    
    override func start() {
        super.start()
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink() {
                _ in

                self.process = self.getProcess()
                self.speed = self.getSpeed()
                self.time = self.getTime()
            }
        
    }
}

extension DLTaskGenre {
    func getProcess() -> CGFloat {
        let total: Float = threads.reduce(0) { $0 + $1.process }
        let proportion: Float = total / Float(threads.count)

        return CGFloat(proportion * 3.6 - 90)
    }
    
    func getSpeed() -> Int64 {
        let total: Int64 = threads.reduce(0) {
            all, current in
            
            guard let bytesWritten = current.bytesWritten else { return all }
            return all + bytesWritten
        }
        return total
    }
    
    func getTime() -> Int64 {
        if speed == 0 {
            return 123123
        }
        
        var totalBytesWritten: Int64 = 0
        for thread in threads {
            if let size = thread.totalBytesWritten {
                totalBytesWritten += size
            }
        }
        
        return (Int64(file!.size) - totalBytesWritten) / speed
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
