//
//  ToHexStringTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCrypto

class KeyDataConvertibleToHexStringTests: XCTestCase {

    func test_0_equals_empty() {
        let data = KeyData(lsbZeroIndexed: [0])
        XCTAssertEqual(data.asHexString(), "0")
    }

    func test1_equals_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1])
        XCTAssertEqual(data.asHexString(), "1")
    }

    func test10_equals_A() {
        let data = KeyData(lsbZeroIndexed: [10])
        XCTAssertEqual(data.asHexString(), "A")
    }

    func testLowercase_10_equals_a() {
        let data = KeyData(lsbZeroIndexed: [10])
        XCTAssertEqual(data.asHexString(uppercased: false), "a")
    }

    func test_0_0_equals_empty() {
        let data = KeyData(lsbZeroIndexed: [0, 0])
        XCTAssertEqual(data.asHexString(), "0")
    }

    func test255_0_0_0_equals_zeros_then_FF_zerosX3() {
        let data = KeyData(lsbZeroIndexed: [0, 0, 0, 255])
        XCTAssertEqual(
            data.asHexString(),
            "FF000000000000000000000000000000000000000000000000"
        )
    }

    func test0_1_equals_zeros_1_zeros() {
        let data = KeyData(lsbZeroIndexed: [0, 1])
        XCTAssertEqual(
            data.asHexString(),
            "10000000000000000"
        )
    }

    func test12_13_equals_DC() {
        let data = KeyData(lsbZeroIndexed: [12, 13])
        XCTAssertEqual(
            data.asHexString(),
            "D000000000000000C"
        )
    }

    func testInt64Max() {
        let data: KeyData = [18446744073709551615]
        XCTAssertEqual(data.asHexString(), "FFFFFFFFFFFFFFFF")
    }
}
