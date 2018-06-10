//
//  ArrayUtilDropTrailingZerosTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class ArrayUtilDropTrailingZerosTests: XCTestCase {
    func testDroppingTrailingZerosEmpty() {
        let array: [Int] = []
        XCTAssertEqual(array.droppingTrailingZeros(), array)
    }

    func testDroppingTrailingZerosSingleZeroIsEmpty() {
        let array: [Int] = [0]
        XCTAssertEqual(array.droppingTrailingZeros(), [])
    }

    func testDroppingTrailingZerosAllZerosIsEmpty() {
        let array: [Int] = [0, 0, 0]
        XCTAssertEqual(array.droppingTrailingZeros(), [])
    }

    func testDroppingTrailingZerosOneFollowedByManyZerosIsOne() {
        let array: [Int] = [1, 0, 0, 0]
        XCTAssertEqual(array.droppingTrailingZeros(), [1])
    }

    func testDroppingTrailingZerosSingleNonZero() {
        let array: [Int] = [1]
        XCTAssertEqual(array.droppingTrailingZeros(), array)
    }

    func testDroppingTrailingZerosAllNonZero() {
        let array: [Int] = [1, 2, 3]
        XCTAssertEqual(array.droppingTrailingZeros(), array)
    }

    func testDroppingTrailingZersoManyValuesButNoTrailingZero() {
        let array: [Int] = [1, 0, 2, 0, 3, 0]
        XCTAssertEqual(array.droppingTrailingZeros(), [1, 0, 2, 0, 3])
    }

    func testDroppingTrailingZeros01() {
        let array: [Int] = [0, 1]
        XCTAssertEqual(array.droppingTrailingZeros(), array)
    }

    func testDroppingTrailingZeros010() {
        let array: [Int] = [0, 1, 0]
        XCTAssertEqual(array.droppingTrailingZeros(), [0, 1])
    }

    func testDroppingTrailingZerosMutatingIsMutating() {
        var array: [Int] = [0]
        XCTAssertEqual(array, [0])
        array.dropTrailingZeros()
        XCTAssertEqual(array, [])
    }

    func testDroppingTrailingZerosNonMutatingIsNonMutating() {
        let array: [Int] = [0]
        XCTAssertEqual(array, [0])
        _ = array.droppingTrailingZeros()
        XCTAssertEqual(array, [0])
    }
}
