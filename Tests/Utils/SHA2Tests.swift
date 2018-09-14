//
//  SHA2Tests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest

@testable import EllipticCurveKit

class SHA2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    private func sha256ConvertToData(_ hexString: String) -> String {
        let data = Data(hex: hexString)
        let digest = Crypto.sha2Sha256(data)
        return digest.toHexString()
    }

    func testsha2sha256ZeroStringsConvertedToData() {
        [
            "": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "00": "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d",
            "0000000000000000000000000000000000000000000000000000000000000000": "66687aadf862bd776c8fc18b8e9f8e20089714856ee233b3902a591d0d5f2925"
            ].forEach {
                XCTAssertEqual(sha256ConvertToData($0), $1)

        }
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
}
