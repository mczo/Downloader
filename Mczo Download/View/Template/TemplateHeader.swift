//
//  TemplateHeader.swift
//  Mczo Download
//
//  Created by Wirspe on 2020/2/6.
//  Copyright © 2020 Wirspe. All rights reserved.
//

import SwiftUI

struct TemplateHeader<Content>: View where Content: View {
    let title: String
    let actions: TemplateListActionRandomAccess<String, () -> Void>
    var content: Content
    
    init(title: String, actions: TemplateListActionRandomAccess<String, () -> Void>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.actions = actions
        self.content = content()
    }
    
    @State private var headerRect: CGRect = CGRect()
    @State private var titleRect: CGRect = CGRect()
    
    var body: some View {
        ZStack {
            
            // 主要
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color("bg"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(GeometryGetter(rect: self.$headerRect))

                    self.content
                }
            }
            
            // 头部
            VStack(spacing: 0) {
                ZStack {
                    VStack {
                        Text(self.title) // position: 17
                            .font(.system(size: 34))
                    }


                    HStack {
                        Spacer()

                        HStack {
                            ForEach(self.actions, id: \.0) { icon, callback, index in
                                Button(action: {
                                    callback()
                                }) {
                                    Image(systemName: icon)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: self.headerHeight)
                .background(Color("fg"))

                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(Color("bg"))
    }
    
    private var currentOffset: CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        return self.headerRect.minY - height
    }
    
    private var headerHeight: CGFloat {
        let height = self.headerRect.height + self.currentOffset

        if height <= 40 {
            return 40
        }
        
        return height
    }
    
}

#if DEBUG
struct TemplateHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TemplateHeader(
                title: "测试",
                actions: TemplateListActionRandomAccess([
                    (
                        key: "plus",
                        value: {
                            print("")
                        }
                    )
                ])
            ) {
                VStack {
                    EmptyView()
                }
                .background(Color.blue)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("bg"))
    }
}
#endif
