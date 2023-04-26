//
//  PublishRelay+PropertyWrappers.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay

extension PublishRelay: RxRelayType, RelayPropertyType, HasBlankInit {}
public typealias PublishRelayObservableProperty<Element> = RelayObservableProperty<PublishRelay<Element>>
public typealias PublishRelayObserverProperty<Element> = RelayObserverProperty<PublishRelay<Element>>
