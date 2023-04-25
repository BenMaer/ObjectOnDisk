//
//  DiskInfo+Retrieve.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

import Disk

public extension DiskInfo {
    typealias RetrieveSuccess<T> = (T) -> Void
    typealias RetrieveFailure = ((RetrieveError) -> Void)?
    enum RetrieveError: Error {
        case fileDoesNotExist
        case error(Error)
    }
    
    func retrieve<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try Disk.retrieve(path, from: directory, as: T.self, decoder: decoder)
    }
    
    func retrieveResult<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = .init()) -> Result<T,RetrieveError> {
        guard DiskInfo(directory: directory, path: path).existsOnDisk else {
            return .failure(.fileDoesNotExist)
        }
        
        do {
            return .success(try retrieve(decoder: decoder))
        } catch {
            return .failure(.error(error))
        }
    }
}
