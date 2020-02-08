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
        List {
            ForEach(failureList) {
                item in
                
                VStack {
                    HStack {
                        Text("\(item.name)")

                        Spacer()
                    }
                    .modifier(DLCompositionTitle())

                    HStack {
                        Text(item.info)

                        Spacer()
                    }
                    .modifier(DLCompositionDescription())
                }
                .contextMenu {
                    DLListMenu(item: item, type: .failure)
                }
            }
            .onDelete {
                indexSet in

                guard let index = indexSet.first else { return }
                
                let item = self.failureList[index]
                fileOperat(item).del()
            }
        }
        .navigationBarTitle(DLStatus.failure.title)
    }
}
