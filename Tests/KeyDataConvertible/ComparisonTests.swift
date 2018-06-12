//
//  ComparisonTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import SwiftCrypto

class ComparisonTests: XCTestCase {
    func testLSB_0_1_greater_than_9() {
        XCTAssertGreaterThan(
            KeyData(lsbZeroIndexed: [0, 1]),
            KeyData(lsbZeroIndexed: [9])
        )
    }

    func testMSB_9_greater_than_0_1() {
        XCTAssertGreaterThan(
            KeyData(msbZeroIndexed: [9]),
            KeyData(msbZeroIndexed: [0, 1])
        )
    }

    func testLSB_9_less_than_0_1() {
        XCTAssertLessThan(
            KeyData(lsbZeroIndexed: [9]),
            KeyData(lsbZeroIndexed: [0, 1])
        )
    }

    func testOneGreaterThanManyZerosSinceTheyShouldHaveBeenRemoved() {
        XCTAssertGreaterThan(
            KeyData(lsbZeroIndexed: [1]),
            KeyData(lsbZeroIndexed: [0, 0, 0])
        )
    }

    func test_IntMaxValue_less_than_0_1() {
        XCTAssertLessThan(
            KeyData(lsbZeroIndexed: [UInt.max]),
            KeyData(lsbZeroIndexed: [0, 1])
        )
    }
}
