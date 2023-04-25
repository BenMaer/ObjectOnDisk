//
//  ReplayRelay+PropertyWrappers.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay

extension ReplayRelay: RxRelayType, RelayPropertyType {}
public typealias ReplayRelayObservableProperty<Element> = RelayManualObservableProperty<ReplayRelay<Element>>
public typealias ReplayRelayObserverProperty<Element> = RelayManualObserverProperty<ReplayRelay<Element>>
