//
//  RelayManualObservableProperty.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxSwift

@propertyWrapper
public struct RelayManualObservableProperty<Relay: RelayPropertyType> {
    public typealias Element = Relay.Element
    public let relay: Relay
    public var wrappedValue: Observable<Element> { relay.asObservable() }
}

extension RelayManualObservableProperty: ObserverType {
    public func on(_ event: RxSwift.Event<Element>) { relay.on(event) }
}
