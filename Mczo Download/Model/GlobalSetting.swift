//
//  GlobalSetting.swift
//  Mczo Download
//
//  Created by Wirspe on 2019/10/23.
//  Copyright © 2019 Wirspe. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<V> {
    let userDefault: UserDefaults = UserDefaults.standard
    let key: String
    let value: V
    
    init(key: String, defaultValue value: V) {
        self.key = key
        self.value = value
    }
    
    var wrappedValue: V {
        get {
            return userDefault.object(forKey: key) as? V ?? value
        }
        set {
            userDefault.set(newValue, forKey: key)
        }
    }
}

final class GlobalSettings: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    struct General {
        @UserDefault(key: "complentedDel", defaultValue: false)
        var complentedDel: Bool
    }
    
    struct Download {
        @UserDefault(key: "thread", defaultValue: 5.0)
        var thread: Float
        
        @UserDefault(key: "shard", defaultValue: 8.0)
        var shard: Float

    }
    
    @Published var general: General = General()
    @Published var download: Download = Download() {
        didSet {
            didChange.send()
        }
    }
}
