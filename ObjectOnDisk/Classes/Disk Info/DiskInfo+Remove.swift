//
//  DiskInfo+Remove.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public extension DiskInfo {
    func remove() throws { try Disk.remove(path, from: directory) }
}
