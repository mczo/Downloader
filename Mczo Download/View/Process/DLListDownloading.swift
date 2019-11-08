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
    @State private var spin: Bool = false
    
    var body: some View {
        ForEach(taskList) {
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
                            Text("100kb")
                            
                            Spacer()
                            
                            Text("剩余1分钟")
                        }
                        .modifier(DLCompositionDescription())
                    }
                }
            }
//        .onReceive(<#T##publisher: Publisher##Publisher#>, perform: <#T##(Publisher.Output) -> Void#>)
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
