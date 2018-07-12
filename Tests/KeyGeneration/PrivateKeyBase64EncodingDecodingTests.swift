//
//  PrivateKeyBase64EncodingDecodingTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCrypto

private let privateKeyHex = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"
private let privateKeyBase64 = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

class PrivateKeyBase64EncodingDecodingTests: XCTest {
    func testPrivateKeyFromBase64() {
        let frombase64 = PrivateKey(base64: privateKeyBase64)!
        let fromHex = PrivateKey(hex: privateKeyHex)!
        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
    }

    func testPrivateKeyBase64Encoding() {
        let frombase64 = PrivateKey(base64: privateKeyBase64)!
        XCTAssertEqual(frombase64.base64Encoded(), privateKeyBase64)
    }

}
