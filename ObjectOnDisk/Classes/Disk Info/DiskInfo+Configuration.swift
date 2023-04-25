//
//  DiskInfo+Configuration.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

public extension DiskInfo {
    class Configuration {
        public var retrieveInBackgroundErrorHandling: RetrieveInBackgroundErrorHandling? = nil
        init() {}
    }
    
    static let configuration = Configuration()
}

public extension DiskInfo.Configuration {
    enum RetrieveInBackgroundErrorHandling {
        case assertionFailure, print
    }
}
