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
    
    @State private var isAdd: Bool = false
    @State private var isEdit: Bool = false
    @State private var tabCurrent: DLStatus = .downloading
    
    var body: some View {
        VStack {
            Group {
                TemplateTab(current: $tabCurrent, btnLeft: $isEdit, btnRight: $isAdd)
                
                if (tabCurrent == .downloading) {
                    DLListDownloading()
                } else if tabCurrent == .complete {
                    DLListComplete()
                } else if tabCurrent == .failure {
                    DLListFailure()
                }
            }
            .padding(.top, 10)
            .transition(.move(edge: .leading))
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
        .background(Color("bg"))
    }
}

#if DEBUG
struct DLList_Previews: PreviewProvider {
    static var previews: some View {
        DLList()
    }
}
#endif

enum DLStatus: Int {
    case wait
    case downloading
    case pause
    case complete
    case failure
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
