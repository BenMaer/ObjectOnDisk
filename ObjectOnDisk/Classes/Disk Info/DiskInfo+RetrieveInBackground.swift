//
//  DiskInfo+RetrieveInBackground.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

public extension DiskInfo {
    func retrieveInBackground<T: Decodable>(as type: T.Type = T.self, decoder: JSONDecoder = .init(), success: @escaping RetrieveSuccess<T>, failure: RetrieveFailure = nil) {
        Self.backgroundQueue.async {
            let retrievedResult = retrieveResult(as: T.self, decoder: decoder)
            
            DispatchQueue.main.async {
                switch retrievedResult {
                case let .success(value):
                    success(value)
                    
                case let .failure(error):
                    if let errorHandling = Self.configuration.retrieveInBackgroundErrorHandling {
                        let message = "Error when retrieving from Disk in background: \(error)"
                        switch errorHandling {
                        case .assertionFailure:
                            assertionFailure(message)
                        case .print:
#if DEBUG
                            print(message)
#endif
                            break
                        }
                    }
                    failure?(error)
                }
            }
        }
    }
}
