//
//  DLList.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/9.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLList: View {
    @State private var selection: DLStatus = .downloading
    @State private var DLAddPresented: Bool = false
    
    @ObservedObject var downloadingManage: DownloadingManage = DownloadingManage()
    
    private var selectionView: some View {
        Section {
            Picker("下载", selection: $selection) {
                Text("下载中").tag(DLStatus.downloading)
                Text("已完成").tag(DLStatus.complete)
                Text("失败").tag(DLStatus.failure)
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                selectionView
                
                if selection == DLStatus.downloading {
                    DLListDownloading(downloadingManage: downloadingManage)
                }
            }
            .navigationBarTitle("下载", displayMode: .automatic)
            .navigationBarItems(
                leading: Button(action: {
                    
                }) {
                    Text("编辑")
                },
                trailing: Button(action: {
                    self.DLAddPresented.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(
                isPresented: self.$DLAddPresented,
                onDismiss: {},
                content: {
                    DLAdd(DLAddPresented: self.$DLAddPresented, downloadingManage: self.downloadingManage)
                }
            )
        }
    }
}


enum DLStatus: Int {
    case wait
    case downloading
    case pause
    case complete
    case failure
}

struct DLCompositionTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
    }
}

struct DLCompositionDescription: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray)
            .font(.callout)
    }
}

extension Int64 {
    var btySize: String {
        var unit: String
        var val: Int16
        
        switch self {
        case let b where b >= 0:
            unit = "B"
            val = Int16(self)
        case let kb where kb >= 1000:
            unit = "KB"
            val = Int16(kb / 1000)
        case let MB where MB >= 1000000:
            unit = "MB"
            val = Int16(MB / 1000000)
        case let GB where GB >= 1000000000:
            unit = "GB"
            val = Int16(GB / 1000000000)
        default:
            return ""
        }
        
        return "\(String(val)) \(String(unit))"
    }
    
    var timeDec: String {
        switch self {
        case let s where s > 0:
            return "\(s) 秒"
        case let m where m >= 60:
            return "\(Int16(m / 60)) 分"
        case let h where h >= 3600:
            return "\(Int16(h / 3600)) 小时"
        case let d where d >= 86400:
            return "\(Int16(d / 86400)) 天"
        default:
            return ""
        }
    }

}
