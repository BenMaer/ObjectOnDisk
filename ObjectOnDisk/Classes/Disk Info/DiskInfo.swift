//
//  DiskInfo.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public struct DiskInfo {
    var directory: Disk.Directory = .applicationSupport
    let path: String
}
