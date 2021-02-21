//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-02-21.
//

import XCTest
@testable import EllipticCurveKit

final class DiffieHellmanTests: XCTestCase {
    
    func testDiffieHellman() {
        let a = PrivateKey<Secp256k1>()
        let A = PublicKey<Secp256k1>(privateKey: a)
        let b = PrivateKey<Secp256k1>()
        let B = PublicKey<Secp256k1>(privateKey: b)
        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(A, B)
        
        let dhA = a * B
        let dhB = b * A
        XCTAssertEqual(dhA, dhB)
    }
    
    // https://crypto.stackexchange.com/q/88083/60476
    func testCyonKeyExchange() {
        let a = PrivateKey<Secp256k1>()
        let A = PublicKey<Secp256k1>(privateKey: a)
        let b = PrivateKey<Secp256k1>()
        let B = PublicKey<Secp256k1>(privateKey: b)
        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(A, B)
        
        let dhA = a * B
        let dhB = b * A
        XCTAssertEqual(dhA, dhB)
        
        let ephemeralPrivate = PrivateKey<Secp256k1>()
        let ephemeralPublic = PublicKey<Secp256k1>(privateKey: ephemeralPrivate)
        
        let cyonA: AffinePoint<Secp256k1> = dhA + ephemeralPublic
        let cyonB = dhB + ephemeralPublic
        
        XCTAssertEqual(cyonA, cyonB)
    }
    
    func testCyonKeyExchangeThreeParties() {
        let a = PrivateKey<Secp256k1>()
        let A = PublicKey<Secp256k1>(privateKey: a)
        let b = PrivateKey<Secp256k1>()
        let B = PublicKey<Secp256k1>(privateKey: b)
        let c = PrivateKey<Secp256k1>()
        let C = PublicKey<Secp256k1>(privateKey: c)
        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(A, B)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(b, c)
        
        let abc: AffinePoint<Secp256k1> = A.point + B + C
        let bca: AffinePoint<Secp256k1> = B.point + C + A
        let cab: AffinePoint<Secp256k1> = C.point + A + B
        XCTAssertEqual(abc, bca)
        XCTAssertEqual(abc, cab)
        XCTAssertEqual(bca, cab)
        
    }
}
