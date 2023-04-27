//
//  BehaviorRelay+PropertyWrappers.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay

extension BehaviorRelay: RxRelayType, RelayPropertyType {}
public typealias BehaviorRelayObserverProperty<Element: HasBlankInit> = RelayObserverProperty<BehaviorRelay<Element>>
public typealias BehaviorRelayObservableProperty<Element: HasBlankInit> = RelayObservableProperty<BehaviorRelay<Element>>

public typealias BehaviorRelayManualObserverProperty<Element> = RelayManualObserverProperty<BehaviorRelay<Element>>
public typealias BehaviorRelayManualObservableProperty<Element> = RelayManualObservableProperty<BehaviorRelay<Element>>

extension OptionalBehaviorRelay: RelayPropertyType, HasBlankInit {}
public typealias OptionalBehaviorRelayObserverProperty<Element> = RelayObserverProperty<OptionalBehaviorRelay<Element>>
public typealias OptionalBehaviorRelayObservableProperty<Element> = RelayObservableProperty<OptionalBehaviorRelay<Element>>
