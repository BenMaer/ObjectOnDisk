//
//  ObjectOnDisk+Factory.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

public struct ObjectOnDiskFactory {
    let diskInfo: DiskInfo
    let decoder: JSONDecoder
    init(diskInfo: DiskInfo, decoder: JSONDecoder = ObjectOnDiskConfiguration.shared.createJSONDecoder()) {
        self.diskInfo = diskInfo
        self.decoder = decoder
    }
    
#if DEBUG
    var debugProperties: DEBUGProperties = .init()
#endif
}

public extension ObjectOnDiskFactory {
#if DEBUG
    struct DEBUGProperties {
        var didFailToLoadFromDisk_assert = false
        
        enum LoadFromDiskForcedAction {
            case ignore, remove
        }
        var loadFromDiskForcedAction: LoadFromDiskForcedAction? = nil
    }
#endif
}
