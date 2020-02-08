//
//  TemplateTab.swift
//  Mczo Download
//
//  Created by Wirspe on 2020/2/2.
//  Copyright © 2020 Wirspe. All rights reserved.
//

import SwiftUI

struct TemplateTab: View {
    @Binding var current: DLStatus
    @Binding var btnLeft: Bool
    @Binding var btnRight: Bool
    
    private let tabs: [DLStatus] = [.downloading, .complete, .failure]
    
    @State private var rect: CGRect = CGRect()
    
    private let height: CGFloat = 32
    private let iconHeight: CGFloat = 11
    
    private func left() -> some View {
        Button(action: {
            self.btnLeft.toggle()
        }) {
            Image(systemName: "list.dash")
                .resizable()
                .frame(width: self.iconHeight, height: self.iconHeight)

        }
        .frame(width: self.height, height: self.height, alignment: .center)
        .foregroundColor(Color("tab-font"))
        .cornerRadius(999)
    }
    
    private func center() -> some View {
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(self.tabs, id: \.self) { item in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.current = item
                        }
                    }) {
                        Spacer()

                        Text(item.title)
                            .font(.system(size: 14))
                            .foregroundColor(Color("tab-font"))

                        Spacer()
                    }
                    .frame(height: 30)
                }
            }
            .background(GeometryGetter(rect: self.$rect))
            
            HStack(spacing: 0) {
                Capsule()
                    .foregroundColor(Color("asset"))
//                    .frame(width: 100, height: 3.5)
                    .frame(width: self.rect.size.width / CGFloat(self.tabs.count), height: 3.5)
                    .offset(x: self.rect.size.width / CGFloat(self.tabs.count) * CGFloat(self.tabs.firstIndex(of: self.current)!))
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        
    }
    
    private func right() -> some View {
        Button(action: {
            self.btnRight.toggle()
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: self.iconHeight, height: self.iconHeight)

        }
        .frame(width: self.height, height: self.height, alignment: .center)
        .foregroundColor(Color("tab-font"))
        .cornerRadius(999)
    }
    
    var body: some View {
        HStack(spacing: 8) {
//            self.left()
            self.center()
//            self.right()
        }
        .padding(.horizontal) // 两边间距
    }

}

#if DEBUG
struct TemplateTab_Previews: PreviewProvider {
    static var previews: some View {
        TemplateTab(current: .constant(.downloading), btnLeft: .constant(false), btnRight: .constant(false))
            .background(Color.white)
    }
}
#endif

extension DLStatus {
    var title: String {
        switch self {
        case .wait:
            return "等待中"
        case .downloading:
            return "下载中"
        case .pause:
            return "已下载"
        case .complete:
            return "已完成"
        case .failure:
            return "失败"
        }
    }
}
