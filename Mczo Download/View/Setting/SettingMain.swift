//
//  SettingMain.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct SettingMain: View {
    @EnvironmentObject private var globalSetting: GlobalSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("一般")) {
                    Toggle(isOn: $globalSetting.general.complentedDel) {
                        Text("分享后删除")
                    }
                }
                
                Section(header: Text("下载")) {
                    NavigationLink(destination: SettingMainThread(thread: $globalSetting.download.thread)) {
                        HStack {
                            Text("最多任务")
                            Spacer()
                            Text("\(Int8(globalSetting.download.thread))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: SettingMainShared(shard: $globalSetting.download.shard)) {
                        HStack {
                            Text("线程数")
                            Spacer()
                            Text("\(Int8(globalSetting.download.shard))")
                                .foregroundColor(.secondary)

                        }
                    }
                }
            }
            .navigationBarTitle("设置", displayMode: .inline)
        }
    }
}



struct SettingMain_Previews: PreviewProvider {
    static var previews: some View {
        SettingMain()
    }
}

struct SettingMainThread: View {
    @Binding var thread: Float
    
    var body: some View {
        VStack(spacing: 5) {
            Slider(
                value: $thread,
                in: 1...15,
                step: 1)
                .padding(.horizontal)
            Text("最多下载任务数: \(Int8(thread))")
        }
    }
}

struct SettingMainShared: View {
    @Binding var shard: Float
    
    var body: some View {
        VStack(spacing: 5) {
            Slider(
                value: $shard,
                in: 1...128,
                step: 1)
                .padding(.horizontal)
            Text("下载线程: \(Int8(shard))")
            
        }
    }
}
