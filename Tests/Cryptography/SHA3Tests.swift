//
//  SHA3Tests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest

@testable import SwiftCrypto

class SHA3Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSHA3() {
        XCTAssertEqual(
            Crypto.sha3Sha256(Data(hex: "616263")).toHexString(),
            "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532"
        )

        XCTAssertEqual(
            Crypto.sha3Sha256(Data(hex: "")).toHexString(),
            "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a"
        )

        XCTAssertEqual(
            "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".sha3(.sha256),
            "41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376"
        )

        let longText = "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
        XCTAssertEqual(
            longText.sha3(.sha256),
            "916f6061fe879741ca6469b43971dfdb28b1a32dc36cb3254e812be27aad1d18"
        )

        XCTAssertEqual(
            longText.sha3(.sha256),
            Crypto.sha3Sha256(longText).toHexString()
        )
    }
}
