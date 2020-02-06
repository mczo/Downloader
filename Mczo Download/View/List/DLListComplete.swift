//
//  DLListComplete.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/23.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yy/MM/dd"
    return dateFormatter
}

struct DLListComplete: View {
    @EnvironmentObject var downloadingManage: DownloadingManage
    @EnvironmentObject private var globalSetting: GlobalSettings
    @FetchRequest(fetchRequest: ModelComplete.sortedFetchRequest) var completeList: FetchedResults<ModelComplete>
    
    @State private var shareShow: Bool = false
        
    var body: some View {
        TemplateList(completeList,
            cover: { item in
                ZStack {
                    Circle()
                        .fill(Color("asset"))

                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
            }, title: { item in
                Text(item.name)
            }, meta: { item in
                Text(item.size.btySize)
                Text(dateFormatter.string(from: item.createdAt))

                Spacer()

                Text(item.ext)
            }, actions: TemplateListActionRandomAccess([
                (
                    key: "ellipsis",
                    value: { index in
                        print(index)
                    }
                ),
                (
                    key: "trash",
                    value: { index in
                        print(index)
                    }
                )
            ]) )
        
    }
}

#if DEBUG
struct DLListComplete_Previews: PreviewProvider {
    static var previews: some View {
        DLListComplete()
    }
}
#endif

fileprivate struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [URL] = Array()
    let applicationActivities: [UIActivity]? = nil
    let delete: Bool
    let fileOperats: [fileOperat]

    init(fileOperats: [fileOperat], delete: Bool) {
        for operat in fileOperats {
            self.activityItems.append(operat.dfm.full)
        }

        self.delete = delete
        self.fileOperats = fileOperats
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in

            if error != nil {
                return
            }

            if completed && self.delete {
                for operat in self.fileOperats {
                    operat.del()
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
