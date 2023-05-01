//
//  XCTAssertFailure.swift
//  ObjectOnDisk_Tests
//
//  Created by Benjamin Maer on 5/1/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

public func XCTAssertFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssert(false, message(), file: file, line: line)
}
