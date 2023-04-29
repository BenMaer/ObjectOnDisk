//
//  DiskInfo+Exists.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public extension DiskInfo {
    var existsOnDisk: Bool {
        guard let url = try? Disk.url(for: path, in: directory) else { return false }
        return Disk.exists(url)
    }
}
