//
//  ArrayUtilDropLeadingZerosTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class ArrayUtilDropLeadingZerosTests: XCTestCase {
    func testDroppingLeadingZerosEmpty() {
        let array: [Int] = []
        XCTAssertEqual(array.droppingLeadingZeros(), array)
    }

    func testDroppingLeadingZerosSingleZeroIsEmpty() {
        let array: [Int] = [0]
        XCTAssertEqual(array.droppingLeadingZeros(), [])
    }

    func testDroppingLeadingZerosAllZerosIsEmpty() {
        let array: [Int] = [0, 0, 0]
        XCTAssertEqual(array.droppingLeadingZeros(), [])
    }

    func testDroppingLeadingZerosSingleNonZero() {
        let array: [Int] = [1]
        XCTAssertEqual(array.droppingLeadingZeros(), array)
    }

    func testDroppingLeadingZerosAllNonZero() {
        let array: [Int] = [1, 2, 3]
        XCTAssertEqual(array.droppingLeadingZeros(), array)
    }

    func testDroppingLeadingZersoManyValuesButNoLeadingZero() {
        let array: [Int] = [1, 0, 2, 0, 3, 0]
        XCTAssertEqual(array.droppingLeadingZeros(), array)
    }

    func testDroppingLeadingZeros01() {
        let array: [Int] = [0, 1]
        XCTAssertEqual(array.droppingLeadingZeros(), [1])
    }

    func testDroppingLeadingZeros010() {
        let array: [Int] = [0, 1, 0]
        XCTAssertEqual(array.droppingLeadingZeros(), [1, 0])
    }

    func testDroppingLeadingZerosMutatingIsMutating() {
        var array: [Int] = [0]
        XCTAssertEqual(array, [0])
        array.dropLeadingZeros()
        XCTAssertEqual(array, [])
    }

    func testDroppingLeadingZerosNonMutatingIsNonMutating() {
        let array: [Int] = [0]
        XCTAssertEqual(array, [0])
        _ = array.droppingLeadingZeros()
        XCTAssertEqual(array, [0])
    }
}
