//
//  RelayObserverProperty.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxSwift

@propertyWrapper
public struct RelayObserverProperty<Relay: RelayPropertyType & HasBlankInit> {
    public typealias Element = Relay.Element
    public let relay = Relay()
    public var wrappedValue: AnyObserver<Element> { relay.asObserver() }
    
    public init() {}
}

extension RelayObserverProperty: ObservableType {
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Relay.Element == Observer.Element { relay.subscribe(observer) }
}
