//
//  BehaviorRelay+PropertyWrappers.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay

extension BehaviorRelay: RxRelayType, RelayPropertyType {}
public typealias BehaviorRelayObservableProperty<Element> = RelayManualObservableProperty<BehaviorRelay<Element>>
public typealias BehaviorRelayObserverProperty<Element> = RelayManualObserverProperty<BehaviorRelay<Element>>

extension OptionalBehaviorRelay: RelayPropertyType, HasBlankInit {}
public typealias OptionalBehaviorRelayObservableProperty<Element> = RelayObservableProperty<OptionalBehaviorRelay<Element>>
public typealias OptionalBehaviorRelayObserverProperty<Element> = RelayObserverProperty<OptionalBehaviorRelay<Element>>
