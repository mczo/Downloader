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
    
    @State private var formURL: String = "https://d1.music.126.net/dmusic/8962/2019827153711/NeteaseMusic_2.2.0_800_web.dmg"
//    @State private var formURL: String = "https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2019.exe"
    @State private var formTitle: String = String()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("输入链接", text: $formURL)
                TextField("自定义标题", text: $formTitle)
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
                    
                    let downloading = DLTaskGenre(url: self.formURL,
                                                   title: self.formTitle,
                                                   shard: Int8(self.globalSetting.download.shard))
                    self.downloadingManage.list.insert(downloading, at: 0)
                }) {
                    Text("完成")
                }
                .disabled(!(self.downloadingManage.list.count < Int(self.globalSetting.download.thread)))
            )
        }
    }
}
