//
//  CreatePublicKeyFromPrivateKeyTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import SwiftCrypto

class CreatePublicKeyFromPrivateKeyTests: XCTestCase {

    func testPublicKeyFromPrivateKey() {

        let publicKey = KeyManager().getPublicKeyFromPrivateKeyString("PASTE_PRIVATE_KEY_FOR_TESTNET_HERE")
        XCTAssertEqual(publicKey?.asHexString(), "F510333720C5DD3C3C08BC8E085E8C981CE74691")
    }

}
