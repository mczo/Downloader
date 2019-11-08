//
//  SettingMain.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/21.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct SettingMain: View {
    @ObservedObject private var global: GlobalSettings = GlobalSettings()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("一般")) {
                    Toggle(isOn: $global.general.complentedDel) {
                        Text("分享后删除")
                    }
                }
                
                Section(header: Text("下载")) {
                    NavigationLink(destination: SettingMainThread(thread: $global.download.thread)) {
                        HStack {
                            Text("最多任务")
                            Spacer()
                            Text("\(global.download.thread.toInt)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: SettingMainShared(shard: $global.download.shard)) {
                        HStack {
                            Text("线程数")
                            Spacer()
                            Text("\(global.download.shard.toInt)")
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
            Text("最多下载任务数: \(thread.toInt)")
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
            Text("下载线程: \(shard.toInt)")
            
        }
    }
}

extension Float {
    var toInt: Int {
        return Int(self)
    }
}
