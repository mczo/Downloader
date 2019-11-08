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
    
    @State var taskList: [DLTaskGenre] = Array()
    
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
                    DLListDownloading(taskList: self.$taskList)
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
                    DLAdd(DLAddPresented: self.$DLAddPresented, taskList: self.$taskList)
                }
            )
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


struct DLList_Previews: PreviewProvider {
    static var previews: some View {
        DLList()
    }
}

enum DLStatus: Int {
    case wait
    case downloading
    case pause
    case complete
    case failure
}
