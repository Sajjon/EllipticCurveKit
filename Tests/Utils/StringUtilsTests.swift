//
//  StringUtilsTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class StringUtilsTests: XCTestCase {
    func testDroppingLeading0xFromEmptyString() {
        let string = ""
        let dropped = string.droppingTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringInWith0xInMiddle() {
        let string = "a0xa"
        let dropped = string.droppingTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "a0xa", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringInWith0xInEnd() {
        let string = "a0a"
        let dropped = string.droppingTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "a0a", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringOnlyContaining0x() {
        let string = "0x"
        let dropped = string.droppingTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(dropped, "", "String only containing 0x should be empty after drop")
        XCTAssertEqual(string, "0x", "Dropping method should not be mutating")
    }

    func testDropLeadingZerosNotNeededUnchanged() {
        func assertUnchanged(_ string: String, _ message: String? = nil, line: Int = #line) {
            let message = message ?? "String `\(string)` should remain unchanged"
            XCTAssertEqual(string, string.droppingLeadingZerosIfNeeded(), message + " line: \(line)")
        }
        assertUnchanged("")
        assertUnchanged("1")
        assertUnchanged("123456789")
        assertUnchanged("abcdef")
        assertUnchanged("123456789abcdef")
        assertUnchanged("10", "Non leading zeros should not be removed")
        assertUnchanged("a0a0", "Non leading zeros should not be removed")
    }

    func testVerifyThatSingleZeroStringDoesNotGetTrimmedToEmptyString() {
        XCTAssertEqual("0", "0".droppingLeadingZerosIfNeeded(), "String `0` should not become empty string")
    }

    func testDropLeadingZerosNeededChanged() {
        XCTAssertEqual("0", "000000".droppingLeadingZerosIfNeeded(), "Several zero string should result single `0`")
        XCTAssertEqual("1", "01".droppingLeadingZerosIfNeeded(), "01 string should result in 1")
        XCTAssertEqual("10", "010".droppingLeadingZerosIfNeeded(), "010 string should result in 10")
    }
}
