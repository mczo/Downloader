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
    @State private var colors: [Color] = Array(repeating: Color("tab-font"), count: 3)
    
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
        .background(Color("list-bg"))
        .cornerRadius(999)
    }
    
    private func center() -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .foregroundColor(Color("list-bg"))
            
            Capsule()
                .frame(width: self.rect.size.width / CGFloat(self.tabs.count))
                .foregroundColor(Color("asset"))
                .offset(x: self.rect.size.width / CGFloat(self.tabs.count) * CGFloat(self.tabs.firstIndex(of: self.current)!))
            
            HStack {
                ForEach(self.tabs, id: \.self) { item in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.colors[self.tabs.firstIndex(of: self.current)!] = Color("tab-font")
                            
                            self.current = item
                            
                            self.colors[self.tabs.firstIndex(of: self.current)!] = Color("tab-font-asset")
                        }
                    }) {
                        Spacer()
                        
                        Text(item.title)
                            .font(.system(size: 14))
                            .foregroundColor(Color.white)
                            .colorMultiply(self.colors[self.tabs.firstIndex(of: item)!])
                        
                        Spacer()
                    }

                }
            }
        }
        .frame(height: self.height)
        .background(GeometryGetter(rect: self.$rect))
        .onAppear {
            self.colors[self.tabs.firstIndex(of: self.current)!] = Color("tab-font-asset")
        }

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
        .background(Color("list-bg"))
        .cornerRadius(999)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            self.left()
            self.center()
            self.right()
        }
        .padding(.horizontal) // 两边间距
    }

}

#if DEBUG
struct TemplateTab_Previews: PreviewProvider {
    static var previews: some View {
        TemplateTab(current: .constant(.downloading), btnLeft: .constant(false), btnRight: .constant(false))
            .background(Color("bg"))
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
