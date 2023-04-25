//
//  OptionalBehaviorRelay.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay
import RxSwift

public final class OptionalBehaviorRelay<OElement> {
    public typealias Element = OElement?
    private let relay = BehaviorRelay<Element>()
    public var value: Element { relay.value }
    
    public init() {}
}

extension OptionalBehaviorRelay: ObservableType {
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Element == Observer.Element { relay.subscribe(observer) }
}

extension OptionalBehaviorRelay: ObserverType {
    public func on(_ event: RxSwift.Event<Element>) { relay.on(event) }
}
