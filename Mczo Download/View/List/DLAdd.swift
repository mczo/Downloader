//
//  DLAdd.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/10.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLAdd: View {
    @ObservedObject var downloadingManage: DownloadingManage
    @ObservedObject var globalSetting: GlobalSettings
    @Binding var DLAddPresented: Bool
    
    let completeModelOperat: ModelOperat = ModelOperat<ModelComplete>()

//    @State private var formURL: String = String()
//    @State private var formURL: String = "https://github.com/Dids/clover-builder/releases/download/v2.5k_r5103/CloverISO-5103.tar.lzma"
    @State private var formURL: String = "https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2019.exe"
    @State private var formTitle: String = String()
    @State private var fileExist: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("一般"), footer: Text(fileExist ? "此文件可能已下载，请更换标题" : "")) {
                    TextArea("下载链接", text: $formURL) {
                        self.fileExist = false
                        
                        if self.formURL.isEmpty {
                            return
                        }
                        
                        for item in self.completeModelOperat.fetch() {
                            if item.url == self.formURL && self.formTitle.isEmpty {
                                self.fileExist = true
                                break
                            }
                        }
                    }

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
                .disabled( downloadingManage.list.count >= Int(globalSetting.download.thread) || formURL.isEmpty || (fileExist && formTitle.isEmpty))
            )
        }
    }
}

fileprivate struct TextArea: View {
    let placeholder: String
    @Binding var text: String
    let height: CGFloat
    let callback: () -> Void
    
    init(_ placeholder: String = "", text: Binding<String>, height: CGFloat = 100, callback: @escaping () -> Void) {
        self.placeholder = placeholder
        self._text = text
        self.height = height
        self.callback = callback
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
            
            UITextArea(text: $text, callback: self.callback)
                .frame(width: nil, height: height, alignment: .topLeading)
        }
    }
    
    struct UITextArea: UIViewRepresentable {
        @Binding var text: String
        let callback: () -> Void
        
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
                self.parent.callback()
            }
        }
    }
}
