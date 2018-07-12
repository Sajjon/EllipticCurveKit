//
//  CreatePublicKeyFromPrivateKeyTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt
//import CommomCryptoPrivate

@testable import SwiftCrypto

// This is a completely uninteresting private key for a wallet with no funds.
private let privateKeyHex = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"
private let privateKeyBase64 = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

class CreatePublicKeyFromPrivateKeyTests: XCTestCase {

    private let privateKey = PrivateKey(hex: privateKeyHex)!

    // this is slow
    private lazy var publicKey = PublicKey(privateKey: privateKey)

    func testPrivateKeyFromBase64() {
        let frombase64 = PrivateKey(base64: privateKeyBase64)!
        let fromHex = PrivateKey(hex: privateKeyHex)!
        XCTAssertEqual(frombase64.number.asHexString(), fromHex.number.asHexString())
    }

    func testPrivateKeyBase64Encoding() {
        let frombase64 = PrivateKey(base64: privateKeyBase64)!
        XCTAssertEqual(frombase64.base64Encoded(), privateKeyBase64)
    }

    // This takes around 43 seconds which of course is terribly unacceptable. My goal is 0.01 seconds.
    func testRestoringPrivateKeyAndVerificationOfSignature() {
        // TEST VECTOR 2: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
        let privateKey = PrivateKey(hex: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF")!

        let keyPair = AnyKeyGenerator<Secp256k1>.restoreKeyPairFrom(privateKey: privateKey, format: .raw)

        let signature = Signature(hex: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD")

        let message = Message(hex: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89")

        XCTAssertTrue(AnyKeySigner<Schnorr<Secp256k1>>.verify(message, wasSignedBy: signature, using: keyPair), "The signature verification should return true")
    }

    func testCreatingPublicKeyAndAddressesFromPrivateKey() {
        XCTAssertEqual(publicKey.x.asHexString(), "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.y.asHexString(), "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        XCTAssertEqual(publicKey.hex.compressed, "02F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.hex.uncompressed, "04F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4FB8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        let testnetAddress = PublicAddress(publicKeyPoint: publicKey, network: .testnet)
        XCTAssertEqual(testnetAddress.base58.uncompressed, "mjdhN2LKkATnmK2bbNQTtcvyxtCyUcPDLY")
        XCTAssertEqual(testnetAddress.base58.compressed, "mtDqt5jYQ5P5vsT6X78B8JmrArV6fM7YjU")
        XCTAssertEqual(testnetAddress.zilliqa, "59BB614648F828A3D6AFD7E488E358CDE177DAA0")

        let mainnetAddress = PublicAddress(publicKeyPoint: publicKey, network: .mainnet)
        XCTAssertEqual(mainnetAddress.base58.uncompressed, "157k4yFLw92XzCYysoS64hif6tcGdDULm6")
        XCTAssertEqual(mainnetAddress.base58.compressed, "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU")
        XCTAssertEqual(mainnetAddress.zilliqa, "59BB614648F828A3D6AFD7E488E358CDE177DAA0") // unknown how to format for mainnet, default to same as testnet for now.


        let expectedMainnetPrivateKeyWIFUncompressed = "5J8kgEmHqTH9VYLd34DP6uGVmwbDXnQFQwDvZndVP4enBqz2GuM"
        let expectedMainnetPrivateKeyWIFCompressed = "KxdDnBkVJrzGUyKc45BeZ3hQ1Mx2JsPcceL3RiQ4GP7kSTX682Jj"

        let mainnetWifs = PrivateKeyWIF(privateKey: privateKey, network: .mainnet)
        XCTAssertEqual(mainnetWifs.uncompressed, expectedMainnetPrivateKeyWIFUncompressed)
        XCTAssertEqual(mainnetWifs.compressed, expectedMainnetPrivateKeyWIFCompressed)

        let expectedTestnetPrivateKeyWIFUncompressed = "91uPFyaqRgMHTbqufQ7HyVpTRbwvgwwSkt5seQyzioPpxsz2QXA"
        let expectedTestnetPrivateKeyWIFCompressed = "cNzDF6kLjvgXeQnsSUzmvNCTdbFRyKVJggUWY8rZmVmkhCdFnSS9"

        let testnetWifs = PrivateKeyWIF(privateKey: privateKey, network: .testnet)
        XCTAssertEqual(testnetWifs.uncompressed, expectedTestnetPrivateKeyWIFUncompressed)
        XCTAssertEqual(testnetWifs.compressed, expectedTestnetPrivateKeyWIFCompressed)

    }


    private func sha256(_ hexString: String) -> String {
        return Crypto.sha2Sha256(hexString).toHexString()
    }


    private func sha256ConvertToData(_ hexString: String) -> String {
        return sha256Data(Data(hex: hexString))
    }


    private func sha256Data(_ data: Data) -> String {
        return Crypto.sha2Sha256(data).toHexString()
    }

    // irrelevant
//    func testsha2sha256ZeroStrings() {
//        [
//            "": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
//            "00": "f1534392279bddbf9d43dde8701cb5be14b82f76ec6607bf8d6ad557f60f304e",
//            "0000000000000000000000000000000000000000000000000000000000000000": "60e05bd1b195af2f94112fa7197a5c88289058840ce7c6df9693756bc6250f55"
//            ].forEach {
//                XCTAssertEqual(sha256($0), $1)
//
//        }
//    }

    func testsha2sha256ZeroStringsConvertedToData() {
        [
            "": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "00": "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d",
            "0000000000000000000000000000000000000000000000000000000000000000": "66687aadf862bd776c8fc18b8e9f8e20089714856ee233b3902a591d0d5f2925"
            ].forEach {
                XCTAssertEqual(sha256ConvertToData($0), $1)

        }
    }

    // THIS IS THE WRONG WAY OF DOING IT, should not use `data(using: String.Encoding)` on String, should be using `Data(hex: String)`
//    func testsha2sha256ZeroStringsData() {
//        [
//            "".data(using: .utf8)! : "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
//            "00".data(using: .utf8)! : "f1534392279bddbf9d43dde8701cb5be14b82f76ec6607bf8d6ad557f60f304e",
//            "0000000000000000000000000000000000000000000000000000000000000000".data(using: .utf8)! : "60e05bd1b195af2f94112fa7197a5c88289058840ce7c6df9693756bc6250f55"
//            ].forEach {
//                XCTAssertEqual(sha256Data($0), $1)
//
//        }
//    }

    func testStringToDataAndBackToString() {
        // WRONG WAY
//        func verifyStringToDataAndBackToString(_ string: String) {
//            let encoding: String.Encoding = .utf8
//            XCTAssertEqual(string, String(data: (string.data(using: encoding)!), encoding: encoding)!)
//        }
        func verifyStringToDataAndBackToString(_ string: String) {
            XCTAssertEqual(string, Data(hex: string).toHexString().uppercased())
        }
        verifyStringToDataAndBackToString("")
        verifyStringToDataAndBackToString("00")
        verifyStringToDataAndBackToString("01")
        verifyStringToDataAndBackToString("11")
        verifyStringToDataAndBackToString("AA")
        verifyStringToDataAndBackToString("A0")
        verifyStringToDataAndBackToString("0000000000000000000000000000000000000000000000000000000000000000")
    }


    // `Test vector 1` at: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
    func testSigningAndVerifyingSignatures1() {
        signingAndVerifyingSignaturesTest(
            privateKey: "0000000000000000000000000000000000000000000000000000000000000001",
            compressedPublicKey: "0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
            uncompressedPublicKey: "0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",
            message: "0000000000000000000000000000000000000000000000000000000000000000",
//            signature: "0582344958B04A9B2BCC63C09222F0540167C846512143B37B1978269737EAE16A7DFD9B9D2F751E99FEDC934E8EC5000AEEC240AFAD10A6A6D9F5D104247A99"
            signature: "787A848E71043D280C50470E8E1532B2DD5D20EE912A45DBDD2BD1DFBF187EF67031A98831859DC34DFFEEDDA86831842CCD0079E1F92AF177F7F22CC1DCED05"
        )
    }

    /// `Test vector 2` at: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
    func testSigningAndVerifyingSignatures2() {
        signingAndVerifyingSignaturesTest(
            privateKey: "B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF",
            compressedPublicKey: "02DFF1D77F2A671C5F36183726DB2341BE58FEAE1DA2DECED843240F7B502BA659",
            uncompressedPublicKey: "04DFF1D77F2A671C5F36183726DB2341BE58FEAE1DA2DECED843240F7B502BA6592CE19B946C4EE58546F5251D441A065EA50735606985E5B228788BEC4E582898",
            message: "243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89",
//            signature: "EB3D32A4DEF40C1CB6F6182BC14CEF27F5BFE8BF649C83DC842E90EE7B380F0AFBB45E1B4A98F564DE7DB8286FAA162258398885DF55007C9D4928BB2AF68196"
            signature: "2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD"
        )
    }

    /// `Test vector 3` at: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#test-vectors
    func testSigningAndVerifyingSignatures3() {
        signingAndVerifyingSignaturesTest(
            privateKey: "C90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B14E5C7",
            compressedPublicKey: "03FAC2114C2FBB091527EB7C64ECB11F8021CB45E8E7809D3C0938E4B8C0E5F84B",
            uncompressedPublicKey: "04FAC2114C2FBB091527EB7C64ECB11F8021CB45E8E7809D3C0938E4B8C0E5F84BC655C2105C3C5C380F2C8B8CE2C0C25B0D57062D2D28187254F0DEB802B8891F",
            message: "5E2D58D8B3BCDF1ABADEC7829054F90DDA9805AAB56C77333024B9D0A508B75C",
//            signature: "002A4FE22683AF06767E083B84A47495A66811EC3706FB54AD17DCD50CD8F9B413188B94DDDD8A406089DEBD22B6EE7B5EF0B0EFBCBC9E59A8A9978CE932941B"
            signature: "00DA9B08172A9B6F0466A2DEFD817F2D7AB437E0D253CB5395A963866B3574BE00880371D01766935B92D2AB4CD5C8A2A5837EC57FED7660773A05F0DE142380"
        )
    }

    private func signingAndVerifyingSignaturesTest(privateKey priHex: String, compressedPublicKey: String, uncompressedPublicKey: String, message mHex: String, signature sigHex: String) {
        let privateKey = PrivateKey(hex: priHex)!
        let publicKey = PublicKey(privateKey: privateKey)

        XCTAssertEqual(publicKey.hex.uncompressed, uncompressedPublicKey)
        XCTAssertEqual(publicKey.hex.compressed, compressedPublicKey)

        let message = Message(hex: mHex)
        let expectedSignature = Signature(hex: sigHex)

        XCTAssertTrue(schnorr_verify(message: message, publicKey: publicKey, signature: expectedSignature))

//        let signatureFromMessage = schnorr_sign(message: message, privateKey: privateKey, publicKey: publicKey)
//        XCTAssertEqual(signatureFromMessage, expectedSignature)
//
//        XCTAssertTrue(schnorr_verify(message: message, publicKey: publicKey, signature: signatureFromMessage))
    }
}
