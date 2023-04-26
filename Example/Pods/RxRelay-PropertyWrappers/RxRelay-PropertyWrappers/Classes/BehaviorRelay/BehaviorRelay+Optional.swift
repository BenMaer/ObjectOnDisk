//
//  BehaviorRelay+Optional.swift
//  RxRelay-PropertyWrappers
//
//  Created by Benjamin Maer on 4/24/23.
//

import Foundation

import RxRelay

extension BehaviorRelay {
    convenience init<T>() where Element == T? { self.init(value: nil) }
}
