//
//  KeyDataStringInitTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

extension KeyData {
    private init?(hexFailable hex: String) {
        do {
            try self.init(hexString: hex)
        } catch {
            XCTFail("Failed to create KeyData with string: `\(hex)`, error: \(error)")
            return nil
        }
    }

    init(hex: String) {
        if let data = KeyData(hexFailable: hex) {
            self = data
        } else {
            XCTFail("Failed to create KeyData with string: `\(hex)`")
            self = KeyData([])
        }
    }
}

class KeyDataStringInitTests: KeyDataTests {

    func testEmptyString() {
        let empty = KeyData(hex: "")
        XCTAssertEqual(empty.length, 0, "KeyData should be created, but with length 0")
    }

    func testOddChars1() {
        do {
            _ = try KeyData(hexString: "1")
        } catch KeyData.Error.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testOddCharsF() {
        do {
            _ = try KeyData(hexString: "F")
        } catch KeyData.Error.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testOddChars100() {
        do {
            _ = try KeyData(hexString: "100")
        } catch KeyData.Error.stringLengthNotEven {
            XCTAssertTrue(true, "Should have failed with this, since length was odd.")
        } catch {
            XCTFail("Should not have failed, got error: `\(error)`")
        }
    }

    func testChars01() {
        let data = KeyData(hex: "01")
        assertEqual(data, [1])
        XCTAssertEqual(data.length, 1, "Two hex charss should result in a single UInt8")
    }

    func testChars0x01() {
        let data = KeyData(hex: "0x01")
        assertEqual(data, [1])
        XCTAssertEqual(data.length, 1, "Two hex charss should result in a single UInt8")
    }

    func testChars0F() {
        let data = KeyData(hex: "0F")
        assertEqual(data, [15])
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt8")
    }

    func testChars10() {
        let data = KeyData(hex: "10")
        assertEqual(data, [16], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt8")
    }

    func testCharsFF() {
        let data = KeyData(hex: "FF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt8")
    }

    func testChars0xFF() {
        let data = KeyData(hex: "0xFF")
        assertEqual(data, [255], "should be equal")
        XCTAssertEqual(data.length, 1, "Two hex chars should result in a single UInt8")
    }

    func testChars0100() {
        let data = KeyData(hex: "0100")
        assertEqual(data, [1, 0], "should be equal")
        XCTAssertEqual(data.length, 2, "Four hex chars should result in a two UInt8")
    }

    func testCharsFFAAFFEC() {
        let data = KeyData(hex: "FFAAFFEC")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt8")
    }

    func testCharsFFAAFFECWithLeadingZeros() {
        let data = KeyData(hex: "00000000FFAAFFEC")
        assertEqual(data, [0, 0, 0, 0, 255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 8, "16 hex chars should result in a eight UInt8")
    }

    func testCharsffaaffec() {
        let data = KeyData(hex: "ffaaffec")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt8")
    }

    func testCharsfFAafFec() {
        let data = KeyData(hex: "fFAafFec")
        assertEqual(data, [255, 170, 255, 236], "should be equal")
        XCTAssertEqual(data.length, 4, "Eight hex chars should result in a four UInt8")
    }
}
