//
//  PrivateKeyBase64EncodingDecodingTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import EllipticCurveKit

private let hex = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"
private let base64 = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

private let hexLeadingZeros = "0000000000000000000000000000000000000000000000000000000000000001"
private let base64LeadingZeros = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE="

class PrivateKeyBase64EncodingDecodingTests: XCTestCase {
    func testPrivateKeyFromBase64() {
        let frombase64 = PrivateKey<Secp256k1>(base64: base64)!
        let fromHex = PrivateKey<Secp256k1>(hex: hex)!
        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
    }

    func testPrivateKeyBase64Encoding() {
        let frombase64 = PrivateKey<Secp256k1>(base64: base64)!
        XCTAssertEqual(frombase64.base64Encoded(), base64)
    }

    func testPrivateKeyFromBase64LeadingZeros() {
        let frombase64 = PrivateKey<Secp256k1>(base64: base64LeadingZeros)!
        let fromHex = PrivateKey<Secp256k1>(hex: hexLeadingZeros)!
        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
    }

    func testPrivateKeyBase64EncodingLeadingZeros() {
        let frombase64 = PrivateKey<Secp256k1>(base64: base64LeadingZeros)!
        XCTAssertEqual(frombase64.base64Encoded(), base64LeadingZeros)
    }

}
