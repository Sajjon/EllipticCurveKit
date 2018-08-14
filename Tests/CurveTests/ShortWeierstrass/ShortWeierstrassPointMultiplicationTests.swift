//
//  ShortWeierstrassPointMultiplicationTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-30.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest

@testable import SwiftCrypto

class ShortWeierstrassPointMultiplicationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testMul() {
        let privateKey = Number(hexString: "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E")!

        let publicKey = secp256k1 * privateKey
        XCTAssertEqual(publicKey.x.asHexString(), "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.y.asHexString(), "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

    }
}

