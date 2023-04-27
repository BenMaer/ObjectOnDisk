//
//  BehaviorRelay+HasBlankInit.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/26/23.
//

import Foundation

import RxRelay

extension BehaviorRelay: HasBlankInit where Element: HasBlankInit {
    public convenience init() { self.init(value: .init()) }
}
