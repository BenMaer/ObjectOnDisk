//
//  DiskInfo+BackgroundQueue.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

extension DiskInfo {
    static let backgroundQueue = DispatchQueue(label: "com.ObjectOnDisk.background", qos: .background)
}
