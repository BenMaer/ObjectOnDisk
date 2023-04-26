//
//  DiskInfo+Save.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public extension DiskInfo {
    func save<T: Encodable>(_ value: T, encoder: JSONEncoder = .init()) throws {
        try Disk.save(value, to: directory, as: path, encoder: encoder)
    }
}
