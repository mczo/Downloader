//
//  ContentView.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/9.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection) {
            DLList()
                .tabItem {
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("下载")
                    }
                }
                .tag(0)
            
            SettingMain()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("设置")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
