//
//  ObjectOnDiskConfiguration.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

public final class ObjectOnDiskConfiguration {
    public var jsonDecoderConstructor: JSONDecoderConstructor = { .init() }
}

public extension ObjectOnDiskConfiguration {
    typealias JSONDecoderConstructor = () -> JSONDecoder
    
    static let shared = ObjectOnDiskConfiguration()
}
