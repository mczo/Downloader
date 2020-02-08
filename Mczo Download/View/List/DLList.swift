//
//  DLList.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/9.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLList: View {
    @EnvironmentObject private var downloadingManage: DownloadingManage
    @EnvironmentObject private var globalSetting: GlobalSettings
    
    @State private var selection: DLStatus = .downloading
    @State private var DLAddPresented: Bool = false
    @State private var isEdit: Bool = false
        
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: DLListDownloading()) {
                        Text(DLStatus.downloading.title)
                    }
                    
                    NavigationLink(destination: DLListComplete()) {
                        Text(DLStatus.complete.title)
                    }

                    NavigationLink(destination: DLListFailure()) {
                        Text(DLStatus.failure.title)
                    }

                }
            }
            .navigationBarTitle("下载")
            .navigationBarItems(
                leading: Button(action: {
                    self.isEdit.toggle()
                }) {
                    Text(self.isEdit ? "完成" : "选择")
                },
                trailing: Button(action: {
                    self.DLAddPresented.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(
                isPresented: self.$DLAddPresented,
                content: {
                    DLAdd(downloadingManage: self.downloadingManage, globalSetting: self.globalSetting, DLAddPresented: self.$DLAddPresented)
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
        case let err where err < 0:
            return ""
        case let b where b < 1000:
            unit = "B"
            val = Int16(self)
        case let kb where kb < 1000000:
            unit = "KB"
            val = Int16(kb / 1000)
        case let mb where mb < 1000000000:
            unit = "MB"
            val = Int16(mb / 1000000)
        default:
            return ""
        }
        
        return "\(String(val)) \(String(unit))"
    }
    
    var timeDec: String {
        switch self {
        case let err where err < 0:
            return ""
        case let s where s < 60:
            return "\(s) 秒"
        case let m where m < 3600:
            return "\(Int16(m / 60)) 分"
        case let h where h < 86400:
            return "\(Int16(h / 3600)) 小时"
        case let d where d < 2592000:
            return "\(Int16(d / 86400)) 天"
        default:
            return ""
        }
    }

}
