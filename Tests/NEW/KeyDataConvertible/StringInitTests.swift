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
    private init?(msbHexFailable hexString: String, separatedBy separator: Separator? = nil) {
        do {
            try self.init(msbZeroIndexed: hexString, separatedBy: separator)
        } catch {
            XCTFail("Failed to create KeyData with string: `\(hexString)`, error: \(error)")
            return nil
        }
    }

    init(msbHex: String, separatedBy separator: Separator? = nil) {
        if let data = Self(msbHexFailable: msbHex, separatedBy: separator) {
            self = data
        } else {
            XCTFail("Failed to create KeyData with string: `\(msbHex)`")
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
        let empty = KeyData(msbHex: "")
        XCTAssertEqual(empty.length, 0, "KeyData should be created, but with length 0")
    }

    func test1() {
        let data = try! KeyData(msbZeroIndexed: "1")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1]))
    }

    func testF() {
        let data = try! KeyData(msbZeroIndexed: "F")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [15]))
    }

    func test100() {
        let data = try! KeyData(msbZeroIndexed: "100")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [256]))
    }

    func test0001() {
        let data = try! KeyData(msbZeroIndexed: "0001")
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1]))
    }

    func test0x0001() {
        let data = KeyData(msbHex: "0x0001")
        assertEqual(data, [1])
        XCTAssertEqual(data.length, 1)
    }

    func test0F() {
        let data = KeyData(msbHex: "0F")
        assertEqual(data, [15])
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func test10() {
        let data = KeyData(msbHex: "10")
        assertEqual(data, [16], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testFF() {
        let data = KeyData(msbHex: "FF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func test0xFF() {
        let data = KeyData(msbHex: "0xFF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testABCD() {
        XCTAssertEqual(KeyData(msbHex: "ABCD").elements, KeyData(msbZeroIndexed: [43981]).elements)
    }

    func testFFAAFFEC() {
        let data = KeyData(msbHex: "FFAAFFEC")
        assertEqual(data, [65450, 65516], "should be equal")
        XCTAssertEqual(data.length, 2)
        XCTAssertEqual(KeyData(msbHex: "ffaaffec"), KeyData(msbHex: "FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "ffaaffec"), KeyData(msbHex: "fFAafFec"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "fFAafFec"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "0FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "00FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "0000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "00000FFAAFFEC"))
        XCTAssertEqual(KeyData(msbHex: "FFAAFFEC"), KeyData(msbHex: "000000FFAAFFEC"))
    }

    func testCommaSeparated_1_comma_2() {
        let data = KeyData(msbHex: "1,2", separatedBy: .comma)
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1, 2]))
    }

    func testCommaSeparated_1_comma_0_comma_2() {
        XCTAssertEqual(
            KeyData(msbHex: "000100000002"),
            KeyData(msbHex: "1,0,2", separatedBy: .comma)
        )
    }

    func testSpaceSeparated_1_space_2() {
        let data = KeyData(msbHex: "1 2", separatedBy: .space)
        XCTAssertEqual(data, KeyData(msbZeroIndexed: [1, 2]))
    }

    func testSpaceSeparated_1_space_0_space_2() {
        XCTAssertEqual(
            KeyData(msbHex: "000100000002"),
            KeyData(msbHex: "1 0 2", separatedBy: .space)
        )
    }

    func testSeparatorMismatchExpectedCommaFoundSpace() {
        do {
            _ = try KeyData(msbZeroIndexed: "1 2", separatedBy: .comma)
        } catch KeyDataConvertibleError.separatorMismatch {
            XCTAssertTrue(true, "Expected `separatorMismatch`")
        } catch {
            XCTFail("Expected error `separatorMismatch`, got `\(error)`")
        }
    }
}
