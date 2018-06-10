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

class KeyDataConvertibleToHexStringTests: KeyDataConvertibleTests {

    func test_0_equals_empty() {
        let data = KeyData(lsbZeroIndexed: [0])
        XCTAssertEqual(data.asHexString(), "")
    }

    func testDefaultArgs_1_equals_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1])
        XCTAssertEqual(data.asHexString(), zeros(then: "1"))
    }

    func testDefaultArgs_10_equals_A() {
        let data = KeyData(lsbZeroIndexed: [10])
        XCTAssertEqual(data.asHexString(), zeros(then: "A"))
    }

    func testLowercase_10_equals_a() {
        let data = KeyData(lsbZeroIndexed: [10])
        XCTAssertEqual(data.asHexString(uppercased: false), zeros(then: "a"))
    }

    func testTrim_1_equals_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: "#")), "1")
    }

    func test_0_0_equals_empty() {
        let data = KeyData(lsbZeroIndexed: [0, 0])
        XCTAssertEqual(data.asHexString(), "")
    }

    func testDefaultArgs_0_1_equals_zeros_1_zeros() {
        let data = KeyData(lsbZeroIndexed: [0, 1])
        XCTAssertEqual(data.asHexString(), [zeros(then: "1"), zeros()].joined())
    }

    func testTrimmingEmptySeparatorNotPossible() {
        XCTAssertEqual(
            KeyData(lsbZeroIndexed: [0, 1]).asHexString(formatting: .trim(nonEmptySeparator: "")),
            KeyData(lsbZeroIndexed: [0, 1]).asHexString()
        )
    }

    func testDefaultArgs_1_0_equals_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1, 0])
        XCTAssertEqual(data.asHexString(), [zeros(then: "1")].joined())
    }

    func testTrimmingSpaceSeparated_1_2_equals_2_space_1() {
        let data = KeyData(lsbZeroIndexed: [1, 2])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: " ")), "2 1")
    }

    func testMsbInitTrimmingSpaceSeparated_1_2_equals_1_space_2() {
        let data = KeyData(msbZeroIndexed: [1, 2])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: " ")), "1 2")
    }

    func testSpaceSeparated_1_1_equals_zeros_1_space_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1, 1])
        XCTAssertEqual(data.asHexString(formatting: .noTrimming(separator: " ")), [zeros(then: "1"), zeros(then: "1")].joined(separator: " "))
    }

    func testCommaSpaceSeparated_1_1_equals_zeros_1_commaspace_zeros_1() {
        let data = KeyData(lsbZeroIndexed: [1, 1])
        XCTAssertEqual(data.asHexString(formatting: .noTrimming(separator: ", ")), [zeros(then: "1"), zeros(then: "1")].joined(separator: ", "))
    }

    func testTrimmingCommaSpaceSeparated_12_13_equals_D_commaspace_C() {
        let data = KeyData(lsbZeroIndexed: [12, 13])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: ", ")), "D, C")
    }

    func testTrimmingPoundSeperated_1_1_equals_1pound1() {
        let data = KeyData(lsbZeroIndexed: [1, 1])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: "#")), "1#1")
    }

    func testLowercaseTrimmingPoundSeperated_10_10_equals_a_pound_a() {
        let data = KeyData(lsbZeroIndexed: [10, 10])
        XCTAssertEqual(data.asHexString(uppercased: false, formatting: .trim(nonEmptySeparator: "#")), "a#a")
    }

    func testTrimmingSpaceSeperated_10_10_equals_A_space_A() {
        let data = KeyData(lsbZeroIndexed: [10, 10])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: " ")), "A A")
    }

    func testTrimmingSpaceSeparated_255_0_equals_FF_0() {
        let data = KeyData(lsbZeroIndexed: [0, 255])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: " ")), "FF 0")
    }

    func testMsbInitLeadingZerosSameHexString() {
        XCTAssertEqual(
            KeyData(msbZeroIndexed: [101]).asHexString(),
            KeyData(msbZeroIndexed: [00101]).asHexString()
        )
    }

    func testTrimmimingSpaceSeparated_255_0_0_0_equals_FF_0_0_0() {
        let data = KeyData(lsbZeroIndexed: [0, 0, 0, 255])
        XCTAssertEqual(data.asHexString(formatting: .trim(nonEmptySeparator: " ")), "FF 0 0 0")
    }

    func testNoTrimmimingSpaceSeparated_255_0_0_0_equals_zeros_then_FF_zerosX3() {
        let separator = " "
        let data = KeyData(lsbZeroIndexed: [0, 0, 0, 255])
        XCTAssertEqual(
            data.asHexString(formatting: .noTrimming(separator: separator)),
            [zeros(then: "FF"), zeros(repeated: 3, separator: separator)].joined(separator: separator)
        )

    }
}

func zeros(repeated: Int = 1, separator: String = "") -> String {
    let string = KeyData.zeros(repeated: repeated, separator: separator)
    XCTAssertEqual(string.count, ((KeyData.elementHexCharacterCount * repeated) + separator.count * (repeated-1)))
    return string
}

func zeros(then nonZero: String) -> String {
    let string = KeyData.zeros(minus: nonZero.count) + nonZero
    XCTAssertEqual(string.count, KeyData.elementHexCharacterCount)
    return string
}

func charThenZeros(_ char: String) -> String {
    let string = char + KeyData.zeros(minus: char.count)
    XCTAssertEqual(string.count, KeyData.elementHexCharacterCount)
    return string
}

extension Int {
    func times(perform: () -> ()) {
        for _ in 0..<self {
            perform()
        }
    }
}

extension KeyDataConvertible {
    static func zeros(minus: Int = 0, repeated: Int = 1, separator: String = "") -> String {
        let count = Self.elementHexCharacterCount - minus
        var array = [String]()
        repeated.times {
            array.append(String(repeating: "0", count: count))
        }
        return array.joined(separator: separator)
    }
}
