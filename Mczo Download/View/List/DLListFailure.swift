//
//  DLListFailure.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/11/23.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import SwiftUI

struct DLListFailure: View {
    @ObservedObject var downloadingManage: DownloadingManage
    @FetchRequest(fetchRequest: ModelFailure.sortedFetchRequest) var failureList: FetchedResults<ModelFailure>
    
    let modelOperat: ModelOperat = ModelOperat<ModelFailure>()
    
    var body: some View {
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
        }
        .onDelete {
            indexSet in

            guard let index = indexSet.first else { return }
            
            let item = self.failureList[index]

            let file: File = File(url: URL(string: item.url)!,
                                  name: item.name,
                                  createdAt: item.createdAt)
            DownloadFileManage(file: file).delete()
            
            self.modelOperat.delete(item: item)
        }    }}
