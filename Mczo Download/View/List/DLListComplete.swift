//
//  DLListComplete.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/23.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLListComplete: View {
    @ObservedObject var downloadingManage: DownloadingManage
    @FetchRequest(fetchRequest: ModelComplete.sortedFetchRequest) var completeList: FetchedResults<ModelComplete>
    @ObservedObject private var globalSetting: GlobalSettings = GlobalSettings()
    
    private let modelOperat: ModelOperat = ModelOperat<ModelComplete>()
    private let downloadURL: URL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    private var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd"
            return dateFormatter
        }
    }
    
    @State private var shareShow: Bool = false
    
    var body: some View {
        ForEach(completeList) {
            item in
            
            VStack {
                HStack {
                    Text("\(item.name)")

                    Spacer()
                }
                .modifier(DLCompositionTitle())

                HStack(alignment: .center, spacing: 5) {
                    Text(item.size.btySize)
                    Text(self.dateFormatter.string(from: item.createdAt))
                    
                    Spacer()
                    
                    Text(item.ext)
                }
                .modifier(DLCompositionDescription())
            }
            .onTapGesture {
                self.shareShow.toggle()
            }
            .sheet(isPresented: self.$shareShow, content: { ActivityViewController(fileName: item.name, delete: self.globalSetting.general.complentedDel) })
            .contextMenu {
                Group {
                    Button(action: {
                        print("a")
                    }) {
                        Text("暂停")
                    }
                    
                    Button(action: {
                        print("a")
                    }) {
                        Text("继续")
                    }
                }
            }
        }
        .onDelete {
            indexSet in

            guard let index = indexSet.first else { return }
            
            let item = self.completeList[index]

            let file: File = File(url: URL(string: item.url)!,
                                  name: item.name,
                                  createdAt: item.createdAt)
            DownloadFileManage(file: file).delete()
            
            self.modelOperat.delete(item: item)
        }
    }
}

private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [URL]
    var applicationActivities: [UIActivity]? = nil
    var delete: Bool
    
    let fileManager: FileManager = FileManager.default
    
    init(fileName: String, delete: Bool) {
        let filePath = try! self.fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
        self.activityItems = [filePath]
        
        self.delete = delete
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            if error != nil {
                return
            }
            
            if completed && self.delete {
                for file in self.activityItems {
                    try! self.fileManager.removeItem(at: file)
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
