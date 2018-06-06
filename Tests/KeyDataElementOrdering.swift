//
//  KeyDataElementOrdering.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto


class KeyDataElementOrdering: KeyDataTests {

    func testInitWithArray_255_0_170() {
        let data = KeyData([255, 0, 170])
        XCTAssertEqual(data[0], 170, "last element in array should be placed at index zero")
        XCTAssertEqual(data[2], 255, "first element in array should be placed at index `count-1` (last)")
    }

    func testInitWithArray_0_0_2_0() {
        let data = KeyData([0, 0, 2, 0])
        XCTAssertEqual(data[0], 0)
        XCTAssertEqual(data[1], 2)
        XCTAssertEqual(data[2], 0)
        XCTAssertEqual(data[3], 0)
    }

    func testInitWithArray_0_3_0_0() {
        let data = KeyData([0, 3, 0, 0])
        XCTAssertEqual(data[0], 0)
        XCTAssertEqual(data[1], 0)
        XCTAssertEqual(data[2], 3)
        XCTAssertEqual(data[3], 0)
    }

    func testInitAndCompareWithArray_0_0_1_2_0() {
        let data = KeyData([0, 0, 1, 2, 0])
        XCTAssertEqual(data.elements, [0, 2, 1, 0, 0])
    }

    func test255FollowedBy31Zeros() {
        var array = Array<UInt8>.init(repeating: 0, count: 32)
        array[0] = 255

        XCTAssertEqual(array, [
          255, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        ])

        let data = KeyData(array)

        XCTAssertEqual(data.length, 32, "Should contain 32 elements")
        XCTAssertEqual(data.elements[0], 0, "Element at index 0 should contain least significant element")
        XCTAssertEqual(data.elements[31], 255, "Element at index 31 (32th element) should contain most significant element")

        assertEqual(data, [
          255, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        ], "Should be 255 followed by 31 zero elements")
    }

    func test255FollowedBy31ZerosExpressibleByArrayLiteral() {
        let data: KeyData =  [
            255, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        ]

        XCTAssertEqual(data.length, 32, "Should contain 32 elements")
        XCTAssertEqual(data.elements[0], 0, "Element at index 0 should contain least significant element")
        XCTAssertEqual(data.elements[31], 255, "Element at index 31 (32th element) should contain most significant element")
    }

    func test255FollowedBy30ZerosFollowedBy236ExpressibleByArrayLiteral() {
        let data: KeyData =  [
            255, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 236
        ]

        XCTAssertEqual(data.length, 32, "Should contain 32 elements")
        XCTAssertEqual(data.elements[0], 236, "Element at index 0 should contain least significant element")
        XCTAssertEqual(data.elements[31], 255, "Element at index 31 (32th element) should contain most significant element")
    }

    func testEmptyInitializerReversesOrder() {
        let array: [UInt8] = [1, 2, 3]
        let data = KeyData(array)
        let designated = KeyData(leastSignigicantElementLeading: array)
        XCTAssertEqual(designated.elements.reversed(), data.elements)
    }

    func testOrderingDesignatedInitializer() {
        let data = KeyData(leastSignigicantElementLeading: [2, 0, 4, 1])
        XCTAssertEqual(data.elements, [2, 0, 4, 1])
    }

    func testOrderingShorthandInitializer() {
        let data = KeyData([2, 0, 4, 1])
        XCTAssertEqual(data.elements, [1, 4, 0, 2])
        assertCollectionsEqual(data, data.elements)
    }

    func testOrderingOfDataUsingCollectionConformance() {
        let data = KeyData(leastSignigicantElementLeading: [2, 0, 4, 1])
        XCTAssertEqual(data.elements, [2, 0, 4, 1])
        assertCollectionsEqual(data, data.elements)
    }

}

func assertCollectionsEqual<C1: Collection, C2: Collection, E: Equatable>(_ rhs: C1, _ lhs: C2) where C1.Element == C2.Element, C1.Element == E {
    let c1 = AnyCollection<E>(rhs)
    let c2 = AnyCollection<E>(lhs)
    XCTAssertEqual(c1.count, c2.count, "Should have same element count")
    for i in 0..<c1.count {
        let index = AnyIndex(i)
        XCTAssertEqual(c1[index], c2[index], "Elemennts should be same")
    }
}
