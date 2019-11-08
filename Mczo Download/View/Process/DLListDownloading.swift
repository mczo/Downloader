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
    @Binding var taskList: [DLTaskGenre]
    
    @ObservedObject private var circle = AnimationCircle()
    
    var body: some View {
        ForEach(taskList) {
            item in
                        
            NavigationLink(destination: Text("a")) {
                HStack {
                    VStack {
                        if item.status == DLStatus.wait {
                            Circle(startAngleRadians: self.circle.startAngleRadians,
                                   endAngleRadians: self.circle.endAngleRadians)
                                .rotation(Angle(degrees: self.circle.currentAngle))
                                .fill(Color.gray)
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
//                        Text((item as! DownloadTask).file?.name)
                        
                        HStack {
                            Text("100kb")
                            
                            Spacer()
                            
                            Text("剩余1分钟")
                        }
                        .modifier(DLCompositionDescription())
                    }
                }
            }
        }
    }
}

class DLTaskGenre: DownloadTask, Identifiable {
    var id: UUID = UUID()
}

extension DLTaskGenre {
    var process: CGFloat {
        get {
            let total: Float = threads.reduce(0) { $0 + $1.process }
            let proportion: Float = total / Float(threads.count)

            return CGFloat(proportion * 3.6 - 90)
        }
    }
}


fileprivate class AnimationCircle: ObservableObject {
    var cancellable: AnyCancellable?
    
    private(set) var startAngleRadians: CGFloat = -CGFloat.pi / 2
    private(set) var endAngleRadians: CGFloat = 10 * CGFloat.pi
    private(set) var progressStartAngleRadians: CGFloat = -90
    private(set) var progressEndAngleRadians: CGFloat = 270
    
    @Published var currentAngle: Double = 0
    
    init() {
        cancellable = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink() {
                _ in
                
                self.currentAngle += 1
            }
    }
}

fileprivate struct Circle: Shape, Animatable {
    var lineWidth: CGFloat = 2
    var startAngleRadians: CGFloat
    var endAngleRadians: CGFloat

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
