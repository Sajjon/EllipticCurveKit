//
//  PrivateKeyWIFFormatTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-13.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCrypto

private let hex = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"
private let base64 = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

private let hexLeadingZeros = "0000000000000000000000000000000000000000000000000000000000000001"
private let base64LeadingZeros = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE="

//class PrivateKeyWIFFormatTests: XCTestCase {
//    func testPrivateKeyWIF() {
//        let frombase64 = PrivateKey(base64: base64)!
//        let fromHex = PrivateKey(hex: hex)!
//        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
//    }
//
//    func testPrivateKeyBase64Encoding() {
//        let frombase64 = PrivateKey(base64: base64)!
//        XCTAssertEqual(frombase64.base64Encoded(), base64)
//    }
//
//    func testPrivateKeyFromBase64LeadingZeros() {
//        let frombase64 = PrivateKey(base64: base64LeadingZeros)!
//        let fromHex = PrivateKey(hex: hexLeadingZeros)!
//        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
//    }
//
//    func testPrivateKeyBase64EncodingLeadingZeros() {
//        let frombase64 = PrivateKey(base64: base64LeadingZeros)!
//        XCTAssertEqual(frombase64.base64Encoded(), base64LeadingZeros)
//    }
//
//}