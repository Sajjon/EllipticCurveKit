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

typealias KeyData = BigUInt

class OrderingTests: XCTestCase {
    func testLeastSignigicantLeadingInitVerifyTralingButNotLeadingZerosAreRemoved() {
        let data = KeyData(lsbZeroIndexed: [0, 0, 1, 2, 0])
        XCTAssertEqual(data.elements, [0, 0, 1, 2], "Data structure store least significant bit at index 0, trailing zeros in array passed should be removed since those are in fact leading zeros in data structure.")
    }

    func testInitMSBIsRemovingLeadingNotTrailingZeros() {
        let data = KeyData(msbZeroIndexed: [0, 0, 1, 2, 0])
        XCTAssertEqual(data.elements, [0, 2, 1], "Using Most Significant Bit Zero Indexed Init we can first remove leading zeros, turning `[0, 0, 1, 2, 0]` int `[1, 2, 0]` and then reversing them `[0, 2, 1]`")
    }

    func testMostSignificantBitFirstIsReverseOfDesignatedInit() {
        let array: [KeyData.Element] = [1, 2, 3]
        let data = KeyData(lsbZeroIndexed: array)
        let data2 = KeyData(msbZeroIndexed: array)
        XCTAssertEqual(data.elements.reversed(), data2.elements)
    }

    func testMostSignificantBitFirstIsReverseOfDesignatedInitNotSameWhenLeadingAndTrailingZerosInvolved() {
        let array: [KeyData.Element] = [0, 0, 1, 2, 0]
        let data = KeyData(lsbZeroIndexed: array)
        let data2 = KeyData(msbZeroIndexed: array)
        XCTAssertNotEqual(data.elements, data2.elements, "Should not be able to compare least and most significant inits when there were leading and trailing zeros.")
        XCTAssertNotEqual(data.elements.reversed(), data2.elements, "Not even using `reversed` should it be possible to compare least and most significant inits when there were leading and trailing zeros.")
    }

    func testExpressibleByArrayLiteralBehavesLikeMostSignificantBitFirst() {
        let data: KeyData = [0, 0, 1, 2, 0]
        let data2 = KeyData(msbZeroIndexed: [0, 0, 1, 2, 0])
        XCTAssertEqual(data, data2)
    }

    func testExpressibleByArrayLiteralNoZerosOrderedReveresed() {
        let data: KeyData = [1, 2, 3]
        XCTAssertEqual(data.elements, [3, 2, 1])
    }

    func testCollectionConformance() {
        let data = KeyData(lsbZeroIndexed: [0, 0, 1, 2, 0])
        XCTAssertEqual(data.startIndex, data.elements.startIndex)
        XCTAssertEqual(data.endIndex, data.elements.endIndex)
        XCTAssertEqual(data.length, data.elements.count)
    }
}
