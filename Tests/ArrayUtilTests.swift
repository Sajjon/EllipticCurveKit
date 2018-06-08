//
//  ArrayUtilTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class ArrayUtilTests: KeyDataTests {
    func testDroppingLeadingZerosEmpty() {
        let array: [Int] = []
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZerosSingleZeroUnchanged() {
        let array: [Int] = [0]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZerosAllZerosUnchanged() {
        let array: [Int] = [0, 0, 0]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZerosSingleNonZero() {
        let array: [Int] = [1]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZerosAllNonZero() {
        let array: [Int] = [1, 2, 3]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZersoManyValuesButNoLeadingZero() {
        let array: [Int] = [1, 0, 2, 0, 3, 0]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), array)
    }

    func testDroppingLeadingZeros01() {
        let array: [Int] = [0, 1]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), [1])
    }

    func testDroppingLeadingZeros010() {
        let array: [Int] = [0, 1, 0]
        XCTAssertEqual(array.droppingLeadingZerosIfNonAllZeroOrEmpty(), [1, 0])
    }
}
