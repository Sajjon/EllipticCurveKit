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

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testPublicKeyFromPrivateKey() {
        // This is a completely uninteresting private key for a wallet with no funds.
        let number = Number(hexString: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e")!

        let publicKey = publicKeyPoint(from: number)
        XCTAssertEqual(publicKey.x.asHexString(), "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.y.asHexString(), "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        XCTAssertEqual(publicKey.compressed(), "02F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.uncompressed(), "04F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4FB8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        let address = PublicAddress(point: publicKey, network: .mainnet)
        XCTAssertEqual(address.base58.uncompressed, "157k4yFLw92XzCYysoS64hif6tcGdDULm6")
        XCTAssertEqual(address.base58.compressed, "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU")
        XCTAssertEqual(address.zilliqa, "59BB614648F828A3D6AFD7E488E358CDE177DAA0")

    }

}
