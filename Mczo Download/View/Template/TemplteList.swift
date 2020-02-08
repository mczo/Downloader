//
//  TemplteList.swift
//  Mczo Download
//
//  Created by Wirspe on 2020/2/2.
//  Copyright © 2020 Wirspe. All rights reserved.
//

import SwiftUI

struct TemplateList<Data, ContentCover, ContentTitle, ContentMeta>: View where Data: RandomAccessCollection, Data.Element: Identifiable, ContentCover: View, ContentTitle: View, ContentMeta: View {
    
    var datas: [Data.Element]
    var cover: (Data.Element) -> ContentCover
    var title: (Data.Element) -> ContentTitle
    var meta: (Data.Element) -> ContentMeta
    var actions: TemplateListActionRandomAccess<String, (Int) -> Void>
    
    init(_ data: Data, @ViewBuilder cover: @escaping (Data.Element) -> ContentCover, @ViewBuilder title: @escaping (Data.Element) -> ContentTitle, @ViewBuilder meta: @escaping (Data.Element) -> ContentMeta, actions: TemplateListActionRandomAccess<String, (Int) -> Void>) {
        self.datas = Array(data)    
        
        self.cover = cover
        self.title = title
        self.meta = meta
        
        self.actions = actions
    }
    
    var body: some View {
            VStack(spacing: 14) {
                Group {
                    ForEach(self.datas.indices) { index in
                        TemplateListItem(index: index, element: self.datas[index], cover: self.cover, title: self.title, meta: self.meta, actions: self.actions)
                            
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 14)
            .padding(.bottom, 14)
        }
}

private struct TemplateListItem<Element, ContentCover, ContentTitle, ContentMeta>: View where Element: Identifiable, ContentCover: View, ContentTitle: View, ContentMeta: View {
    
    var index: Int
    var element: Element
    
    var cover: (Element) -> ContentCover
    var title: (Element) -> ContentTitle
    var meta: (Element) -> ContentMeta
    
    var actions: TemplateListActionRandomAccess<String, (Int) -> Void>
    private let actionGap: CGFloat = 5
    
    @GestureState private var translation: CGFloat = .zero
    @State private var offsetX: CGFloat = .zero
    private let dragMin: CGFloat = -50
    private var dragMax: CGFloat {
        CGFloat(self.actions.count * -50)
    }
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .updating(self.$translation) { value, state, _ in
                let recoup: CGFloat = value.translation.width > 0 ? -20 : 20
                
                if self.offsetX + value.translation.width < self.dragMax - recoup {
                    let currentWidth: CGFloat = self.offsetX + value.translation.width
                    let originWidth: CGFloat = self.offsetX == .zero ? self.dragMax : .zero
                    
                    state = originWidth + (currentWidth + recoup - self.dragMax) * 0.15
                } else {
                    state = value.translation.width + recoup
                }
            }
            .onEnded { value in
                if self.offsetX + value.translation.width > self.dragMin {
                    self.offsetX = .zero
                } else {
                    self.offsetX = self.dragMax
                }
            }
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                ZStack {
                    ForEach(self.actions, id: \.0) { key, value, btnIndex in
                        Button(action: {
                            value(self.index)
                        }) {
                            Image(systemName: key)
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
                        .background(Color("asset"))
                        .cornerRadius(999)
                        .animation(.interactiveSpring())
                        .offset( x: self.translation * CGFloat(btnIndex) * CGFloat(Float(1) / Float(self.actions.count)) )
                        .offset( x: self.offsetX * CGFloat(btnIndex) * CGFloat(Float(1) / Float(self.actions.count)) )
                    }
                }
            }
            
            HStack(spacing: 12) {
                VStack {
                    self.cover(self.element)
                }
                .foregroundColor(Color("fg"))
                .frame(width: 40, height: 40)
                
                VStack(spacing: 2) {
                    HStack {
                        self.title(self.element)
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("font"))
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        self.meta(self.element)
                    }
                    .foregroundColor(Color("list-font-meta"))
                    .font(.system(size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(height: 60, alignment: .center)
            .padding(.horizontal, 12)
            .background(Color("fg"))
            .cornerRadius(13)
            .animation(.interactiveSpring())
            .offset(x: self.translation)
            .offset(x: self.offsetX)
            .simultaneousGesture(self.dragGesture)
//            .contextMenu {
//                Button(action: {
//
//                }) {
//                    Text("a")
//                }
//            }
        }
        
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}

#if DEBUG
struct TemplateList_Previews: PreviewProvider {
    @State static var testList: [TestList] = [
        TestList(name: "SwiftUI", description: "10 MB"),
        TestList(name: "knowledge", description: "10 MB"),
        TestList(name: "Building a dynamic", description: "10 MB")
    ]
    
    static var previews: some View {
        TemplateList(
            self.testList,
            cover: { item in
                ZStack {
                    Circle()
                        .fill(Color("asset"))

                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
            }, title: { item in
                Text(item.name)
            }, meta: { item in
                Text(item.description)
        }, actions: TemplateListActionRandomAccess([
            (
                key: "ellipsis",
                value: { index in
                    print(index)
                }),
                (
                    key: "pencil",
                    value: { index in
                        print(index)
                }),
                (
                    key: "trash",
                    value: { index in
                        print(index)
                })
            ]))
        .background(Color("bg"))
    }
    
    struct TestList: Identifiable {
        var id: UUID = UUID()
        
        let name: String
        let description: String
    }

}
#endif

class TemplateListActionRandomAccess<Key, Value>: RandomAccessCollection {
    
    var startIndex: Int = 0
    var endIndex: Int { datas.count }

    private(set) var datas: [(key: Key, value: Value)]

    init(_ datas: [(key: Key, value: Value)]) {
        self.datas = datas
    }
    
    subscript(position: Int) -> (Key, Value, Int) {
        return (key: datas[position].key, value: datas[position].value, index: datas.count - 1 - position)
    }
}
