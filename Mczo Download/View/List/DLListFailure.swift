//
//  DLListFailure.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/23.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLListFailure: View {
    @EnvironmentObject var downloadingManage: DownloadingManage
    @FetchRequest(fetchRequest: ModelFailure.sortedFetchRequest) var failureList: FetchedResults<ModelFailure>
    
    var body: some View {
        TemplateList(
            failureList,
            cover: { item in
                ZStack {
                    Circle()
                        .fill(Color("asset"))

                    Image(systemName: "multiply")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
            }, title: { item in
                Text(item.name)
            }, meta: { item in
                Text(item.info)
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
struct DLListFailure_Previews: PreviewProvider {
    static var previews: some View {
        DLListFailure()
    }
}
#endif
