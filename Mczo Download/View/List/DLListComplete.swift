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
    
    private var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd"
            return dateFormatter
        }
    }
    
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
        }
        .onDelete {
            index in
            
            print(index)
        }
    }
}
