//
//  ObjectOnDiskConfiguration.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

public final class ObjectOnDiskConfiguration {
    public var jsonDecoderConstructor: JSONDecoderConstructor = { .init() }
    public var jsonEncoderConstructor: JSONEncoderConstructor = { .init() }
}

public extension ObjectOnDiskConfiguration {
    typealias JSONDecoderConstructor = () -> JSONDecoder
    typealias JSONEncoderConstructor = () -> JSONEncoder

    static let shared = ObjectOnDiskConfiguration()
    
    func createJSONDecoder() -> JSONDecoder { jsonDecoderConstructor() }
    func createJSONEncoder() -> JSONEncoder { jsonEncoderConstructor() }
}
