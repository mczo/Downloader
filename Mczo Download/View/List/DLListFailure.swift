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
    @FetchRequest(fetchRequest: ModelComplete.sortedFetchRequest) var completeList: FetchedResults<ModelComplete>
    
    var body: some View {
        ForEach(downloadingManage.list) {
            item in
            
            VStack {
                HStack {
                    Text("\(item.file.name)")

                    Spacer()
                }
                .modifier(DLCompositionTitle())

                HStack {
                    Text(item.speed.btySize)

                    Spacer()

                    Text(item.time.timeDec)
                }
                .modifier(DLCompositionDescription())
            }
        }
    }}
