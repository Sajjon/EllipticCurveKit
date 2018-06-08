//
//  KeyDataStringInitTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

extension KeyDataStruct {
    private init?(hexFailable hex: String) {
        do {
            try self.init(hexString: hex)
        } catch {
            XCTFail("Failed to create KeyDataStruct with string: `\(hex)`, error: \(error)")
            return nil
        }
    }

    init(hex: String) {
        if let data = KeyDataStruct(hexFailable: hex) {
            self = data
        } else {
            XCTFail("Failed to create KeyDataStruct with string: `\(hex)`")
            self = KeyDataStruct([])
        }
    }
}

class KeyDataStringInitTests: KeyDataTests {

    func testEmptyString() {
        let empty = KeyDataStruct(hex: "")
        XCTAssertEqual(empty.length, 0, "KeyDataStruct should be created, but with length 0")
    }

    func testOddChars1() {
        do {
            _ = try KeyDataStruct(hexString: "1")
        } catch KeyDataError.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testOddCharsF() {
        do {
            _ = try KeyDataStruct(hexString: "F")
        } catch KeyDataError.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testOddChars100() {
        do {
            _ = try KeyDataStruct(hexString: "100")
        } catch KeyDataError.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testChars01() {
        let data = KeyDataStruct(hex: "01")
        assertEqual(data, [1])
        XCTAssertEqual(data.length, 1, "Two hex charss should result in a single UInt64")
    }

    func testChars0x01() {
        let data = KeyDataStruct(hex: "0x01")
        assertEqual(data, [1])
        XCTAssertEqual(data.length, 1, "Two hex charss should result in a single UInt64")
    }

    func testChars0F() {
        let data = KeyDataStruct(hex: "0F")
        assertEqual(data, [15])
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testChars10() {
        let data = KeyDataStruct(hex: "10")
        assertEqual(data, [16], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testCharsFF() {
        let data = KeyDataStruct(hex: "FF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testChars0xFF() {
        let data = KeyDataStruct(hex: "0xFF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt64")
    }

    func testChars0100() {
        let data = KeyDataStruct(hex: "0100")
        assertEqual(data, [1, 0], "should be equal")
        XCTAssertEqual(data.length, 2, "Four hex chars should result in a two UInt64")
    }

    func testCharsFFAAFFEC() {
        let data = KeyDataStruct(hex: "FFAAFFEC")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt64")
    }

    func testCharsFFAAFFECWithLeadingZeros() {
        let data = KeyDataStruct(hex: "00000000FFAAFFEC")
        assertEqual(data, [0, 0, 0, 0, 255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 8, "16 hex chars should result in a eight UInt64")
    }

    func testCharsffaaffec() {
        let data = KeyDataStruct(hex: "ffaaffec")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt64")
    }

    func testCharsfFAafFec() {
        let data = KeyDataStruct(hex: "fFAafFec")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt64")
    }
}
