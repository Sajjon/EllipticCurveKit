//
//  StringUtilsTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class StringUtilsTests: KeyDataTests {
    func testDroppingLeading0xFromEmptyString() {
        let string = ""
        let dropped = string.dropTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringInWith0xInMiddle() {
        let string = "a0xa"
        let dropped = string.dropTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "a0xa", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringInWith0xInEnd() {
        let string = "a0a"
        let dropped = string.dropTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(string, dropped, "String without leading should not change")
        XCTAssertEqual(string, "a0a", "Dropping method should not be mutating")
    }

    func testDroppingLeading0xFromStringOnlyContaining0x() {
        let string = "0x"
        let dropped = string.dropTwoLeadinHexCharsIfNeeded()
        XCTAssertEqual(dropped, "", "String only containing 0x should be empty after drop")
        XCTAssertEqual(string, "0x", "Dropping method should not be mutating")
    }

    func testSplittingEmptyInto1() {
        let string = ""
        let array = try! string.splitIntoSubStringsOfLength(1)
        XCTAssertEqual(string, "", "Splitting should not be mutating")
        XCTAssertEqual(array.count, 0, "Should be 0 elements in array")
    }

    func testSplittingEmptyIntoTwo() {
        let string = ""
        let array = try! string.splitIntoSubStringsOfLength(2)
        XCTAssertEqual(string, "", "Splitting should not be mutating")
        XCTAssertEqual(array.count, 0, "Should be 0 elements in array")
    }

    func testSplittingMethodFourParts() {
        let string = "abcd"
        let array = try! string.splitIntoSubStringsOfLength(1)
        XCTAssertEqual(string, "abcd", "Splitting should not be mutating")
        XCTAssertEqual(array.count, 4, "Should be 4 elements in array")
        XCTAssertEqual(array[0], "a", "first char should be `a`")
        XCTAssertEqual(array[1], "b", "second char should be `b`")
        XCTAssertEqual(array[2], "c", "third char should be `c`")
        XCTAssertEqual(array[3], "d", "fourth char should be `d`")
    }

    func testSplittingMethodTwoParts() {
        let string = "abcd"
        let array = try! string.splitIntoSubStringsOfLength(2)
        XCTAssertEqual(string, "abcd", "Splitting should not be mutating")
        XCTAssertEqual(array.count, 2, "Should be 2 elements in array")
        XCTAssertEqual(array[0], "ab", "first char should be `ab`")
        XCTAssertEqual(array[1], "cd", "second char should be `cd`")
    }

    func testSplittingMethodSingPart() {
        let string = "abcd"
        let array = try! string.splitIntoSubStringsOfLength(4)
        XCTAssertEqual(string, "abcd", "Splitting should not be mutating")
        XCTAssertEqual(array.count, 1, "Should be 1 elements in array")
        XCTAssertEqual(array[0], "abcd", "first char should be `abcd`")
    }

    func testSplittingMethodOddCharCountTwoParts() {
        do {
            _ = try "abc".splitIntoSubStringsOfLength(2)
        } catch KeyData.Error.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testSearchForHexStringRegexpEmpty() {
        XCTAssertTrue("".containsOnlyHexChars(), "Empty strings should pass as true")
    }

    func testSearchForHexStringRegexpJustLeading0x() {
        XCTAssertTrue("0x".containsOnlyHexChars(), "`0x` should pass as true")
    }

    func testSearchForHexStringRegexpAllDifferent() {
        let hexString = "0123456789abcdef"
        XCTAssertTrue(hexString.containsOnlyHexChars(), "Should be valid")
        XCTAssertEqual(hexString, "0123456789abcdef", "Calling contain method should not be mutating")
    }

    func testSearchForHexStringRegexpAllDifferentLeading0x() {
        let hexString = "0x0123456789abcdef"
        XCTAssertTrue(hexString.containsOnlyHexChars(), "Should be valid")
        XCTAssertEqual(hexString, "0x0123456789abcdef", "Calling contain method should not be mutating")
    }

    func testSearchForHexStringRegexpInvalidSymbols() {
        XCTAssertFalse("g".containsOnlyHexChars(), "`g` is not a valid string")
        XCTAssertFalse("0xg".containsOnlyHexChars(), "`0xg` is not a valid string")
        XCTAssertFalse("h".containsOnlyHexChars(), "`h` is not a valid string")
        XCTAssertFalse("012345j1".containsOnlyHexChars())
        XCTAssertFalse("032p5bai".containsOnlyHexChars())
        XCTAssertFalse("032nfds91".containsOnlyHexChars())
        XCTAssertFalse("0123456789abcdefg".containsOnlyHexChars(), "Containing `g` is invalid")
    }

    func testSearchForHexStringRegexpOddLengthShouldBeOK() {
        let hexString = "1a2"
        XCTAssertTrue(hexString.containsOnlyHexChars(), "`1a2` (odd length) has should pass")
    }

    func testSearchForHexStringRegexpOddLengthShouldBeOKLeading0x() {
        let hexString = "0x1a2"
        XCTAssertTrue(hexString.containsOnlyHexChars(), "`0x1a2` (odd length) has should pass")
    }
}
