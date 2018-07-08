//
//  SHA2Tests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest

@testable import SwiftCrypto

class SHA2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSha256CryptoSwift() {
        // https://en.bitcoin.it/wiki/Test_Cases
        let message = "hello"
        let sha2Sha256Data = message.bytes.sha256()
        let sha2Sha256Hex = sha2Sha256Data.toHexString()

        XCTAssertEqual(
            sha2Sha256Hex,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        )

        let sha2Sha256sha2Sha256Hex = sha2Sha256Data.sha256().toHexString()

        XCTAssertEqual(
            sha2Sha256sha2Sha256Hex,
            "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50"
        )
        
    }
    
    func testSha256SwiftCrypto() {
        // https://en.bitcoin.it/wiki/Test_Cases
        let message = "hello"

        XCTAssertEqual(
            Crypto.sha2Sha256(message).toHexString(),
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        )

        XCTAssertEqual(
            Crypto.sha2Sha256_twice(message).toHexString(),
            "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50"
        )
        
    }
}
