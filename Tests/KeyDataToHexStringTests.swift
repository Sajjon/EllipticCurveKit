//
//  KeyDataToHexStringTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//


import XCTest
@testable import SwiftCrypto

class KeyDataToHexStringTests: KeyDataTests {

    func testToHexStringEmpty() {
        let data: KeyData = []
        let hexString = data.asHexString()
        XCTAssertEqual("", hexString, "Empty data should result in empty hexstring")
        assertEqual(data, [], "Hex String functions should not mutate data")
    }

    func testToHexStringZero() {
        let data: KeyData = [0]
        let hexString = data.asHexString()
        XCTAssertEqual("00", hexString, "`[0]` should result in `00` hex representation")
        assertEqual(data, [0], "Hex String functions should not mutate data")
    }

    func testToHexStringTwoZeroCommaSeperated() {
        let data: KeyData = [0, 0]
        let hexString = data.asHexString(separator: ", ")
        XCTAssertEqual("00, 00", hexString, "`[0, 0]` should result in `00, 00` hex representation")
        assertEqual(data, [0, 0], "Hex String functions should not mutate data")
    }

    func testToHexStringTwoElevensCommaSeperated() {
        let data: KeyData = [11, 11]
        let hexString = data.asHexString(separator: ", ")
        XCTAssertEqual("0B, 0B", hexString, "`[11, 11]` should result in `0B, 0B` hex representation")
        assertEqual(data, [11, 11], "Hex String functions should not mutate data")
    }

    func testToHexStringTwoElevensPlusSeperated() {
        let data: KeyData = [11, 11]
        let hexString = data.asHexString(separator: "+")
        XCTAssertEqual("0B+0B", hexString, "`[11, 11]` should result in `0B+0B` hex representation")
        assertEqual(data, [11, 11], "Hex String functions should not mutate data")
    }

    func testToHexStringAUppercase() {
        let data: KeyData = [10]
        let uppercase = data.asHexString()
        XCTAssertEqual("0A", uppercase, "`[10]` should result in `0A` hex representation")
        assertEqual(data, [10], "Hex String functions should not mutate data")
    }

    func testToHexStringALowerrcase() {
        let data: KeyData = [10]
        let lowercase = data.asHexString(uppercased: false)
        XCTAssertEqual("0a", lowercase, "`[10]` should result in `0a` hex representation")
        assertEqual(data, [10], "Hex String functions should not mutate data")
    }

    func testToHexStringLeadingZeros() {
        let data: KeyData = [0, 0, 0, 10, 9, 0, 15]
        let hexString = data.asHexString(separator: ", ")
        XCTAssertEqual("00, 00, 00, 0A, 09, 00, 0F", hexString, "`[0, 0, 0, 10, 9, 0, 15]` should result in `00, 00, 00, 0A, 09, 00, 0F` hex representation")
        assertEqual(data, [0, 0, 0, 10, 9, 0, 15], "Hex String functions should not mutate data")
    }

    func testToHex16() {
        let data: KeyData = [16]
        let hexString = data.asHexString()
        XCTAssertEqual("10", hexString, "`[16]` should result in `10` hex representation")
        assertEqual(data, [16], "Hex String functions should not mutate data")
    }

    func testToHex255() {
        let data: KeyData = [255]
        let hexString = data.asHexString()
        XCTAssertEqual("FF", hexString, "`[255]` should result in `FF` hex representation")
        assertEqual(data, [255], "Hex String functions should not mutate data")
    }

    func testToHex255255() {
        let data: KeyData = [255, 255]
        let hexString = data.asHexString()
        XCTAssertEqual("FFFF", hexString, "`[255, 255]` should result in `FFFF` hex representation")
        assertEqual(data, [255, 255], "Hex String functions should not mutate data")
    }

    func testToHex255170255() {
        let data: KeyData = [255, 170, 255]
        let hexString = data.asHexString()
        XCTAssertEqual("FFAAFF", hexString, "`[255, 170, 255]` should result in `FFAAFF` hex representation")
        assertEqual(data, [255, 170, 255], "Hex String functions should not mutate data")
    }

    func testToHex255With30ZeroElementsFollowedBy170() {
        var array = Array<UInt8>.init(repeating: 0, count: 32)
        array[0] = 255
        array[31] = 170
        let data = KeyData(array)
        let hexString = data.asHexString()
        XCTAssertEqual("FF000000000000000000000000000000000000000000000000000000000000AA", hexString, "`[255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 170]` should result in `FF000000000000000000000000000000000000000000000000000000000000AA` hex representation")
    }
}
