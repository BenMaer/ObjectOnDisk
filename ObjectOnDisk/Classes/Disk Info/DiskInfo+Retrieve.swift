//
//  DiskInfo+Retrieve.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public extension DiskInfo {
    typealias RetrieveSuccess<T> = (T?) -> Void
    typealias RetrieveFailure = ((Error) -> Void)?
    func retrieve<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = .init()) throws -> T {
        return try Disk.retrieve(path, from: directory, as: T.self, decoder: decoder)
    }
    
    func retrieveResult<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = .init()) -> Result<T?,Error> {
        guard DiskInfo(directory: directory, path: path).existsOnDisk else {
            return .success(nil)
        }
        
        do {
            return .success(try retrieve(decoder: decoder))
        } catch {
            return .failure(error)
        }
    }
}
