//
//  DiskInfo+SaveInBackground.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/25/23.
//

import Foundation

extension DiskInfo {
    func saveInBackground<T: Encodable>(_ value: T?, encoder: JSONEncoder = .init(), completion: SaveCompletion = nil) throws {
        let completionOnMain: SaveCompletion = {
            guard let completion = completion else { return nil }
            return { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }()
        
        Self.backgroundQueue.async {
            do {
                if let valueToSave = value {
                    try save(valueToSave, encoder: encoder)
                }
                else if existsOnDisk {
                    try remove()
                }
                
                completionOnMain?(true)
            } catch {
                assertionFailure("Couldn't save with error: \(error)")
                completionOnMain?(false)
            }
        }
    }
}
