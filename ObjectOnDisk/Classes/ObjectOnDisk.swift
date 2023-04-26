//
//  ObjectOnDisk.swift
//  ObjectOnDisk
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxCocoa
import RxRelay
import RxRelay_PropertyWrappers
import RxSwift

public final class ObjectOnDisk<Wrapped: ObjectOnDiskWrappedRequirements> {
    @PublishRelayObservableProperty public var didFinishDiskSave: Observable<DidFinishDiskSaveResult>
    @OptionalBehaviorRelayObservableProperty public var object: Observable<Wrapped?>
    
    public init(
        diskInfo: DiskInfo,
        decoder: JSONDecoder = configuration.createJSONDecoder(),
        encoder: JSONEncoder = configuration.createJSONEncoder()
    ) {
        self.diskInfo = diskInfo
        self.decoder = decoder
        self.encoder = encoder
    }
    
    private let diskInfo: DiskInfo
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let loadFromDiskState: BehaviorRelay<LoadFromDiskState> = .init(value: .none)
    private let disposeBag = DisposeBag()
    
#if DEBUG
    private var debugProperties: Factory.DEBUGProperties = .init()
#endif
}

public typealias ObjectOnDiskWrappedRequirements = Codable & Equatable

public extension ObjectOnDisk {
    typealias DidFinishDiskSaveResult = Result<Wrapped?,Error>
    typealias Configuration = ObjectOnDiskConfiguration
    
    static var configuration: Configuration { .shared }
    var configuration: Configuration { Self.configuration }
    
    func loadFromDisk(completion: @escaping () -> Void) {
        guard loadFromDiskState.value == .none else {
            assertionFailure("`loadFromDiskState` should be `.none`")
            completion()
            return
        }
        
        loadFromDiskState.accept(.loading)
        
        let final: (Result<Wrapped?, Error>) -> Void = { [weak base = self] result in
            switch result {
            case let .success(o):   base?.didLoadFromDisk(o)
            case let .failure(e):   base?.didFailToLoadFromDisk(e)
            }
            completion()
        }
        
#if DEBUG
        if let forcedAction = debugProperties.loadFromDiskForcedAction {
            switch forcedAction {
            case .ignore:
                final(.success(nil))
                return
            case .remove:
                saveToDisk(nil)
                final(.success(nil))
                return
            }
        }
#endif
        
        loadFromDisk(success: { final(.success($0)) }, failure: { final(.failure($0)) })
    }
    
    func update(object: Wrapped?, completion: DiskInfo.SaveCompletion = nil) {
        guard loadFromDiskState.value == .finished else {
            assertionFailure("loadFromDiskState.value should be .finished, instead was \(loadFromDiskState.value)")
            completion?(false)
            return
        }
        
        _object.onNext(object)
        
        saveToDisk(object, completion: completion)
    }
    
    var updateObject: Binder<Wrapped?> { .init(self, binding: { $0.update(object: $1) }) }
}

public extension ObjectOnDisk {
    typealias Factory = ObjectOnDiskFactory
    
    convenience init(factory: Factory) {
        self.init(diskInfo: factory.diskInfo, decoder: factory.decoder)
#if DEBUG
        self.debugProperties = factory.debugProperties
#endif
    }
}

fileprivate enum ObjectOnDiskPrivateTypes {
    enum LoadFromDiskState: Equatable {
        case none, loading, finished
    }
}

private extension ObjectOnDisk {
    typealias PrivateTypes = ObjectOnDiskPrivateTypes
    typealias LoadFromDiskState = PrivateTypes.LoadFromDiskState
    
    func loadFromDisk(success: @escaping (Wrapped?) -> Void, failure: @escaping (Error) -> Void) {
        diskInfo.retrieveInBackground(decoder: decoder, success:success, failure: failure)
    }
    
    func didLoadFromDisk(_ object: Wrapped?) {
        _object.onNext(object)
        loadFromDiskState.accept(.finished)
    }
    
    func didFailToLoadFromDisk(_ error: Error) {
#if DEBUG
        if debugProperties.didFailToLoadFromDisk_assert {
            assertionFailure("Failed to load object from disk with error: \(error)")
        }
#endif
        try? diskInfo.remove()
        loadFromDiskState.accept(.finished)
    }
    
    func saveToDisk(_ object: Wrapped?, completion: DiskInfo.SaveCompletion = nil) {
        do { try diskInfo.saveInBackground(object, encoder: encoder, completion: completion) }
        catch { completion?(false) }
    }
}
