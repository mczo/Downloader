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
                HStack {
                    VStack {
                        if item.status == DLStatus.wait {
                            Circle()
                                .fill(Color.gray)
                                .rotationEffect(.degrees(self.spin ? 360: 0))
                                .animation(Animation.linear(duration: 1.1).repeatForever(autoreverses: false))
                                .onAppear() {
                                    self.spin.toggle()
                                }
                        } else {
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


                    VStack {
                        HStack {
                            Text(item.file!.name)
                                .modifier(DLCompositionTitle())

                            Spacer()
                        }

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
    }
}



class DownloadingManage: ObservableObject {
    private var cancellable: AnyCancellable?
    
    @Published var list: [DLTaskGenre] = []
    
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

                guard let totalBytesWritten = current.totalBytesWritten else { return -1 }
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


