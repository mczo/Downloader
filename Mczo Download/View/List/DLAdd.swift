//
//  DLAdd.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/10.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLAdd: View {
    @Binding var DLAddPresented: Bool
    
    @ObservedObject private var globalSetting: GlobalSettings = GlobalSettings()
    @ObservedObject var downloadingManage: DownloadingManage
    
//    @State private var formURL: String = String()
//    @State private var formURL: String = "https://d1.music.126.net/dmusic/8962/2019827153711/NeteaseMusic_2.2.0_800_web.dmg"
    @State private var formURL: String = "https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2019.exe"
    @State private var formTitle: String = String()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("一般")) {
                    TextArea("下载链接", text: $formURL)
                    
                    TextField("自定义标题", text: $formTitle)
                }
            }
            .navigationBarTitle(Text("添加"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.DLAddPresented.toggle()
                }) {
                    Text("取消")
                },
                trailing: Button(action: {
                    self.DLAddPresented.toggle()
                    
                    let downloading = DLTaskGenre(  url: self.formURL,
                                                    title: self.formTitle,
                                                    shard: Int8(self.globalSetting.download.shard) )
                    
                    self.downloadingManage.list.insert(downloading, at: 0)
                }) {
                    Text("完成")
                }
                .disabled( self.downloadingManage.list.count >= Int(self.globalSetting.download.thread) || self.formURL.isEmpty )
            )
        }
    }
}

fileprivate struct TextArea: View {
    let placeholder: String
    @Binding var text: String
    let height: CGFloat
    
    init(_ placeholder: String = "", text: Binding<String>, height: CGFloat = 100) {
        self.placeholder = placeholder
        self._text = text
        self.height = height
    }
        
    var body: some View {
        ZStack {
            if text.isEmpty {
                Text(placeholder)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(.lightGray))
                    .padding(.top, 9)
                    .padding(.leading, 5)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
            }
            
            UITextArea(text: $text)
                .frame(width: nil, height: height, alignment: .topLeading)
        }
    }
    
    struct UITextArea: UIViewRepresentable {
        @Binding var text: String
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func makeUIView(context: Context) -> UITextView {
                let view = UITextView()
        
                view.delegate = context.coordinator
                view.isScrollEnabled = true
                view.isEditable = true
                view.isUserInteractionEnabled = true
                view.font = UIFont.preferredFont(forTextStyle: .body)
                view.text = text
                view.backgroundColor = .none
        
                return view
            }
        
        func updateUIView(_ view: UITextView, context: Context) {
            view.text = text
        }
        
        final class Coordinator : NSObject, UITextViewDelegate {
            var parent: UITextArea

            init(_ uiTextView: UITextArea) {
                self.parent = uiTextView
            }

            func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                return true
            }

            func textViewDidChange(_ textView: UITextView) {
                self.parent.text = textView.text
            }
        }
    }
}
