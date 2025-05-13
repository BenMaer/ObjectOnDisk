//
//  RelayManualObservableProperty+ReplayRelay.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 5/8/24.
//

import Foundation

import RxRelay

public extension RelayManualObservableProperty {
    init<Element>(bufferSize: Int) where Relay == ReplayRelay<Element> {
        self.init(relay: .create(bufferSize: bufferSize))
    }
}
