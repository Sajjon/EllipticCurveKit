//
//  OrderingTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import SwiftCrypto

class OrderingTests: XCTestCase {

    func testInitMSBIsRemovingLeadingNotTrailingZeros() {
        XCTAssertEqual(
            KeyData(msbZeroIndexed: [0, 0, 1, 2, 0]),
            KeyData(lsbZeroIndexed: [0, 2, 1]),
            "Using Most Significant Bit Zero Indexed Init we can first remove leading zeros, turning `[0, 0, 1, 2, 0]` int `[1, 2, 0]` and then reversing them `[0, 2, 1]`")
    }

    func testExpressibleByArrayLiteralBehavesLikeMostSignificantBitFirst() {
        let data: KeyData = [0, 0, 1, 2, 0]
        let data2 = KeyData(msbZeroIndexed: [0, 0, 1, 2, 0])
        XCTAssertEqual(data, data2)
    }

    func testExpressibleByArrayLiteralNoZerosOrderedReveresed() {
        let data: KeyData = [1, 2, 3]
        XCTAssertEqual(data, KeyData(lsbZeroIndexed: [3, 2, 1]))
    }
}
