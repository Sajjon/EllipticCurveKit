//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-02-12.
//

import XCTest
import CryptoKit
import BigInt

@testable import EllipticCurveKit

final class BitcoinAddressFromPrivateKeyTests: XCTestCase {
    
    // MARK: Tests
    func testSecret() {
        let seed = "secret".toData().sha256()
        let seedHex = seed.toHexString()
        
        XCTAssertEqual(
            seedHex, "2bb80d537b1da3e38bd30361aa855686bde0eacd7162fef6a25fe97bf527a25b"
        )
        
        let privateKey = PrivateKey<Secp256k1>(hex: seedHex)!
        let publicKey = PublicKey<Secp256k1>(privateKey: privateKey)
        
 
        XCTAssertEqual(
            publicKey.hex.compressed,
            "03A02B9D5FDD1307C2EE4652BA54D492D1FD11A7D1BB3F3A44C4A05E79F19DE933"
        )
        
        let address = PublicAddress(publicKeyPoint: publicKey, system: Bitcoin(.mainnet))
        
        XCTAssertEqual(
            address.base58.uncompressed.value,
            "18vqhhW4oPu3Y8hvzTqsHB8LDVrZHupXNC"
        )
    }
}
