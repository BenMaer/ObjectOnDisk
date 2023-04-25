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
    public init(diskInfo: DiskInfo, decoder: JSONDecoder = ObjectOnDiskConfiguration.shared.createJSONDecoder()) {
        self.diskInfo = diskInfo
        self.decoder = decoder
    }
    
#if DEBUG
    public var debugProperties: DEBUGProperties = .init()
#endif
}

#if DEBUG
public extension ObjectOnDiskFactory {
    struct DEBUGProperties {
        public var didFailToLoadFromDisk_assert = false
        public var loadFromDiskForcedAction: LoadFromDiskForcedAction? = nil
        
        public init(didFailToLoadFromDisk_assert: Bool = false, loadFromDiskForcedAction: LoadFromDiskForcedAction? = nil) {
            self.didFailToLoadFromDisk_assert = didFailToLoadFromDisk_assert
            self.loadFromDiskForcedAction = loadFromDiskForcedAction
        }
    }
}

public extension ObjectOnDiskFactory.DEBUGProperties {
    public enum LoadFromDiskForcedAction {
        case ignore, remove
    }
}

#endif
