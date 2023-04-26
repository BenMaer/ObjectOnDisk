//
//  DiskInfo.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public struct DiskInfo {
    var directory: Directory = directory
    let path: String
    
    public init(directory: Directory = directory, path: String) {
        self.directory = directory
        self.path = path
    }
}

public extension DiskInfo {
    typealias Directory = Disk.Directory
    
    static var directory: Directory = .applicationSupport
}
