//
//  StringInitTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

extension KeyDataConvertible {

    init(msbAtIndex0 string: String, radix: Int = 16) {
        if let data = Self(msbZeroIndexed: string, radix: radix) {
            self = data
        } else {
            XCTFail("Failed to create KeyData with string: `\(string)`")
            self = Self(msbZeroIndexed: [])
        }
    }
}

class KeyDataConvertibleTests: XCTestCase {
    func assertEqual(_ lhs: KeyData, _ rhs: KeyData, _ message: String = "", line: Int = #line) {
        XCTAssertEqual(lhs, rhs, message + ", line: \(line)")
    }
}

class StringInitTests: KeyDataConvertibleTests {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testEmptyString() {
        let data = KeyData(msbZeroIndexed: "")
        XCTAssertNotNil(data, "KeyData should be created, but with length 0")
    }

    func test1() {
        let data = KeyData(msbAtIndex0: "1")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1]))
        XCTAssertEqual(data.asHexString(), "1")
        XCTAssertEqual(data.asDecimalString(), "1")
    }

    func testF() {
        let data = KeyData(msbAtIndex0: "F")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [15]))
        XCTAssertEqual(data.asHexString(), "F")
        XCTAssertEqual(data.asDecimalString(), "15")
    }

    func test100() {
        let data = KeyData(msbAtIndex0: "100")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [256]))
        XCTAssertEqual(data.asHexString(), "100")
        XCTAssertEqual(data.asDecimalString(), "256")
    }

    func test0001() {
        let data = KeyData(msbAtIndex0: "0001")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1]))
        XCTAssertEqual(data.asHexString(), "1")
        XCTAssertEqual(data.asDecimalString(), "1")
    }

    func test0x0001() {
        let data = KeyData(msbAtIndex0: "0x0001")
        assertEqual(data, [1])
        XCTAssertEqual(data.asHexString(), "1")
        XCTAssertEqual(data.asDecimalString(), "1")
    }

    func test0F() {
        let data = KeyData(msbAtIndex0: "0F")
        assertEqual(data, [15])
        XCTAssertEqual(data.asHexString(), "F")
        XCTAssertEqual(data.asDecimalString(), "15")
    }

    func test10() {
        let data = KeyData(msbAtIndex0: "10")
        assertEqual(data, [16], "should be equal")
        XCTAssertEqual(data.asHexString(), "10")
        XCTAssertEqual(data.asDecimalString(), "16")
    }

    func testFF() {
        let data = KeyData(msbAtIndex0: "FF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.asHexString(), "FF")
        XCTAssertEqual(data.asDecimalString(), "255")
    }

    func test0xFF() {
        let data = KeyData(msbAtIndex0: "0xFF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.asHexString(), "FF")
        XCTAssertEqual(data.asDecimalString(), "255")
    }

    func testABCD() {
        XCTAssertEqual(KeyData(msbAtIndex0: "ABCD"), KeyData(msbZeroIndexed: [43981]))
    }

    func testFFAAFFEC() {
        let data = KeyData(msbAtIndex0: "FFAAFFEC")
        assertEqual(data, [4289396716], "should be equal")
        XCTAssertEqual(data.asHexString(), "FFAAFFEC")
        XCTAssertEqual(data.asDecimalString(), "4289396716")
        XCTAssertEqual(KeyData(msbAtIndex0: "ffaaffec"), KeyData(msbAtIndex0: "FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "ffaaffec"), KeyData(msbAtIndex0: "fFAafFec"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "fFAafFec"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "0FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "00FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "0000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "00000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbAtIndex0: "FFAAFFEC"), KeyData(msbAtIndex0: "000000FFAAFFEC"))
    }

    func testFx16SingleDigit() {
        let data = KeyData(msbAtIndex0: "FFFFFFFFFFFFFFFF")
        assertEqual(data, [18446744073709551615])
        XCTAssertEqual(data.asHexString(), "FFFFFFFFFFFFFFFF")
        XCTAssertEqual(data.asDecimalString(), "18446744073709551615")
    }

    func test1_16x0_TwoDigits() {
        let data = KeyData(msbAtIndex0: "10000000000000000")
        assertEqual(data, [1, 0])
        XCTAssertEqual(data.asHexString(), "10000000000000000")
        XCTAssertEqual(data.asDecimalString(), "18446744073709551616")
    }

}
