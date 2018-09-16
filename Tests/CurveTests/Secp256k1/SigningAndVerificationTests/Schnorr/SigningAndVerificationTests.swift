//
//  SigningAndVerificationTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticCurveKit

// The three test vectors below are found at:
//  https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
class SignignAndVerificationTests: XCTestCase {

    func testSigFromZilliqaWallet() {
        signingAndVerifyingSignaturesTest(
            // Some uninteresting Zilliqa TESTNET private key, containing a few worthless TEST tokens.
            privateKey: "0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638",
            compressedPublicKey: "034ae47910d58b9bde819c3cffa8de4441955508db00aa2540db8e6bf6e99abc1b",
            message: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019CA91EB535FB92FDA5094110FDAEB752EDB9B039034ae47910d58b9bde819c3cffa8de4441955508db00aa2540db8e6bf6e99abc1b000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000",
            signature: "58a1d11298c80452b91ab3e562bc7160bea8dd49a877885d48a17f3ad4d886d6b94a4413a88630686068485588e80a4cae088fa330ed6a657cf134907157aa64"
        )
    }

    
    // `Test vector 1`
    func testSigningAndVerifyingSignatures1() {
        signingAndVerifyingSignaturesTest(
            privateKey: "0000000000000000000000000000000000000000000000000000000000000001",
            compressedPublicKey: "0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
            uncompressedPublicKey: "0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",
            message: "0000000000000000000000000000000000000000000000000000000000000000",
            signature: "787A848E71043D280C50470E8E1532B2DD5D20EE912A45DBDD2BD1DFBF187EF67031A98831859DC34DFFEEDDA86831842CCD0079E1F92AF177F7F22CC1DCED05"
        )
    }
    
    /// `Test vector 2`
    func testSigningAndVerifyingSignatures2() {
        signingAndVerifyingSignaturesTest(
            privateKey: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF",
            compressedPublicKey: "02DFF1D77F2A671C5F36183726DB2341BE58FEAE1DA2DECED843240F7B502BA659",
            uncompressedPublicKey: "04DFF1D77F2A671C5F36183726DB2341BE58FEAE1DA2DECED843240F7B502BA6592CE19B946C4EE58546F5251D441A065EA50735606985E5B228788BEC4E582898",
            message: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89",
            signature: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD"
        )
    }
    
    /// `Test vector 3`
    func testSigningAndVerifyingSignatures3() {
        signingAndVerifyingSignaturesTest(
            privateKey: "C90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B14E5C7",
            compressedPublicKey: "03FAC2114C2FBB091527EB7C64ECB11F8021CB45E8E7809D3C0938E4B8C0E5F84B",
            uncompressedPublicKey: "04FAC2114C2FBB091527EB7C64ECB11F8021CB45E8E7809D3C0938E4B8C0E5F84BC655C2105C3C5C380F2C8B8CE2C0C25B0D57062D2D28187254F0DEB802B8891F",
            message: "5E2D58D8B3BCDF1ABADEC7829054F90DDA9805AAB56C77333024B9D0A508B75C",
            signature: "00DA9B08172A9B6F0466A2DEFD817F2D7AB437E0D253CB5395A963866B3574BE00880371D01766935B92D2AB4CD5C8A2A5837EC57FED7660773A05F0DE142380"
        )
    }
    
    private func signingAndVerifyingSignaturesTest(privateKey priHex: String, compressedPublicKey: String, uncompressedPublicKey: String? = nil, message mHex: String, signature sigHex: String) {
        
        let privateKey = PrivateKey<Secp256k1>(hex: priHex)!
        let keyPair = AnyKeyGenerator<Secp256k1>.restoreKeyPairFrom(privateKey: privateKey)
        let publicKey = keyPair.publicKey
        if let uncompressedPublicKey = uncompressedPublicKey {
            XCTAssertEqual(publicKey.hex.uncompressed, uncompressedPublicKey)
        }
        XCTAssertEqual(publicKey.hex.compressed, compressedPublicKey)
        
        let message = Message(hex: mHex)
        let expectedSignature = Signature<Secp256k1>(hex: sigHex)!
        
        XCTAssertTrue(AnyKeySigner<Schnorr<Secp256k1>>.verify(message, wasSignedBy: expectedSignature, publicKey: publicKey))
        
        let signatureFromMessage = AnyKeySigner<Schnorr<Secp256k1>>.sign(message, using: keyPair)
        XCTAssertEqual(signatureFromMessage, expectedSignature)
    }
}
