//
//  DLListMenu.swift
//  Mczo Download
//
//  Created by Wirspe on 2020/1/30.
//  Copyright © 2020 Wirspe. All rights reserved.
//

import SwiftUI
import CoreData

struct DLListMenu: View {
    @EnvironmentObject private var downloadingManage: DownloadingManage
    @EnvironmentObject private var globalSetting: GlobalSettings
    
    let item: CoreDataDownload & Managed
    let type: DLStatus
    
    var body: some View {
        Group {
            if self.type != DLStatus.downloading {
                Button(action: {
                    fileOperat(self.item).del()

                    let downloading = DLTaskGenre(  url: self.item.url,
                                                    title: String(),
                                                    shard: Int8(self.globalSetting.download.shard) )

                    self.downloadingManage.list.insert(downloading, at: 0)
                }) {
                    Text("重新下载")
                    Image(systemName: "goforward")
                }
            }
            
            Button(action: {
                UIPasteboard.general.string = self.item.url
            }) {
                Text("复制链接")
                Image(systemName: "link")
            }
            
            Button(action: {
                fileOperat(self.item).del()
            }) {
                Text("删除")
                Image(systemName: "trash")
            }

        }
    }
}

struct fileOperat {
    let dfm: DownloadFileManage
    let item: CoreDataDownload & Managed
    
    var modelOperat: ModelOperatProtocol!

    init(_ item: CoreDataDownload & Managed) {
        let file: File = File(  url: URL(string: item.url)!,
                                name: item.name,
                                createdAt: item.createdAt)

        self.dfm = DownloadFileManage(file: file)
        self.item = item
        
        if item is ModelDownloading {
            modelOperat = ModelOperat<ModelDownloading>()
        } else if item is ModelComplete {
            modelOperat = ModelOperat<ModelComplete>()
        } else if item is ModelFailure {
            modelOperat = ModelOperat<ModelFailure>()
        }
    }

    func del() {
        dfm.delete()
        modelOperat.delete(item: item)
    }
}
