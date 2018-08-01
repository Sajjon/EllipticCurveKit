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
        let secp256k1 = ShortWeierstraßCurve(
            a: Number(0),
            b: Number(7),
            galoisField: Field(modulus: Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!)
        )
        let generator = ShortWeierstraßCurve.Affine(
            Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!,
            Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
        )

        XCTAssertEqual(generator.x, Secp256k1.generator.x)
        XCTAssertEqual(generator.y, Secp256k1.generator.y)
//
//        func both(_ n: Number) {
//            let new = affineMultiplication(n, point: generator, curve: secp256k1)
//            let old = Secp256k1.generator * n
//            XCTAssertEqual(new.x, old.x)
//            XCTAssertEqual(new.y, old.y)
//
//        }
//
//        for i in Number(2)..<Number(100) {
//            both(i)
//        }

        let privateKey = Number(hexString: "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E")!

        let publicKey = affineMultiplication(privateKey, point: generator, curve: secp256k1)
        XCTAssertEqual(publicKey.x.asHexString(), "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.y.asHexString(), "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

    }
}

