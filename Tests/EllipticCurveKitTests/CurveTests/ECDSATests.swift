//
//  ECDSATests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-19.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import CryptoKit
import BigInt

@testable import EllipticCurveKit

/// Test vectors from [trezor][trezor], signature data from [oleganza][oleganza]
///
/// More vectors can be founds on bitcointalk forum, [here][bitcointalk1] and [here][bitcointalk2] (unreliable?)
///
/// [trezor]: https://github.com/trezor/trezor-crypto/blob/957b8129bded180c8ac3106e61ff79a1a3df8893/tests/test_check.c#L1959-L1965
/// [oleganza]: https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoinTestsOSX/BTCKeyTests.swift
/// [bitcointalk1]: https://bitcointalk.org/index.php?topic=285142.msg3300992#msg3300992
/// [bitcointalk2]: https://bitcointalk.org/index.php?topic=285142.msg3299061#msg3299061
///
final class ECDSATests: XCTestCase {

    // MARK: Tests
    
    func testSecp256r1Vector1() {
        verifyRFC6979WithSignature(
            curve: Secp256r1.self,
            key: "c9afa9d845ba75166b5c215767b1d6934e50c3db36e89b127b8a622b120f6721",
            message: "sample",
            expected: (
                k: "a6e3c57dd01abe90086538398355dd4c3b17aa873382b0f24d6129493d8aad60",
                r: "efd48b2aacb6a8fd1140dd9cd45e81d69d2c877b56aaf991c34d0ea84eaf3716",
                s: "f7cb1c942d657c41d436c7a1b6e29f65f3e900dbb9aff4064dc4ab2f843acda8",
                der: "3046022100efd48b2aacb6a8fd1140dd9cd45e81d69d2c877b56aaf991c34d0ea84eaf3716022100f7cb1c942d657c41d436c7a1b6e29f65f3e900dbb9aff4064dc4ab2f843acda8"
            )
        )
    }

    func testSecp256r1Vector2() {
        verifyRFC6979WithSignature(
            curve: Secp256r1.self,
            key: "c9afa9d845ba75166b5c215767b1d6934e50c3db36e89b127b8a622b120f6721",
            message: "test",
            expected: (
                k: "d16b6ae827f17175e040871a1c7ec3500192c4c92677336ec2537acaee0008e0",
                r: "f1abb023518351cd71d881567b1ea663ed3efcf6c5132b354f28d3b0b7d38367",
                s: "19f4113742a2b14bd25926b49c649155f267e60d3814b4c0cc84250e46f0083",
                der: "3045022100f1abb023518351cd71d881567b1ea663ed3efcf6c5132b354f28d3b0b7d383670220019f4113742a2b14bd25926b49c649155f267e60d3814b4c0cc84250e46f0083"
            )
        )
    }

    func testSecp256k1Vector1() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "CCA9FBCC1B41E5A95D369EAA6DDCFF73B61A4EFAA279CFC6567E8DAA39CBAF50",
            message: "sample",
            expected: (
                k: "2df40ca70e639d89528a6b670d9d48d9165fdc0febc0974056bdce192b8e16a3",
                r: "af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b3842",
                s: "5009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124",
                der: "3045022100af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b384202205009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124"
            )
        )
    }


    func testSecp256k1Vector2() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "0000000000000000000000000000000000000000000000000000000000000001",
            message: "Satoshi Nakamoto",
            expected: (
                k: "8f8a276c19f4149656b280621e358cce24f5f52542772691ee69063b74f15d15",
                r: "934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d8",
                s: "2442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5",
                der: "3045022100934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d802202442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5"
            )
        )
    }

    func testSecp256k1Vector3() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140",
            message: "Satoshi Nakamoto",
            expected: (
                k: "33a19b60e25fb6f4435af53a3d42d493644827367e6453928554f43e49aa6f90",
                r: "fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d0",
                s: "6b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5",
                der: "3045022100fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d002206b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5"
            )
        )
    }

    func testSecp256k1Vector4() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "f8b8af8ce3c7cca5e300d33939540c10d45ce001b8f252bfbc57ba0342904181",
            message: "Alan Turing",
            expected: (
                k: "525a82b70e67874398067543fd84c83d30c175fdc45fdeee082fe13b1d7cfdf1",
                r: "7063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c",
                s: "58dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea",
                der: "304402207063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c022058dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea"
            )
        )
    }

    func testSecp256k1Vector5() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "0000000000000000000000000000000000000000000000000000000000000001",
            message: "All those moments will be lost in time, like tears in rain. Time to die...",
            expected: (
                k: "38aa22d72376b4dbc472e06c3ba403ee0a394da63fc58d88686c611aba98d6b3",
                r: "8600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b",
                s: "547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21",
                der: "30450221008600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b0220547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21"
            )
        )
    }

    func testSecp256k1Vector6() {
        verifyRFC6979WithSignature(
            curve: Secp256k1.self,
            key: "e91671c46231f833a6406ccbea0e3e392c76c167bac1cb013f6f1013980455c2",
            message: "There is a computer disease that anybody who works with computers knows about. It's a very serious disease and it interferes completely with the work. The trouble with computers is that you 'play' with them!",
            expected: (
                k: "1f4b84c23a86a221d233f2521be018d9318639d5b8bbd6374a8a59232d16ad3d",
                r: "b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b",
                s: "279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6",
                der: "3045022100b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b0220279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6"
            )
        )
    }
}

// MARK: Helpers
private extension ECDSATests {
    
    func verifyRFC6979<C: EllipticCurve>(
        curve: C.Type,
        key privateKeyHex: String,
        message messageToHash: String,
        expected: (k: String, r: String?, s: String?, der: String?),
        line: UInt
    ) {

        if expected.r == nil && expected.s == nil && expected.der == nil {
            XCTFail("Cannot run test if no expected signature data was provided", line: line)
            return
        }

        let privateKey = PrivateKey<C>(hex: privateKeyHex)!
        let publicKey = PublicKey(privateKey: privateKey)
        let keyPair = KeyPair(private: privateKey, public: publicKey)
        let message = Message(message: messageToHash)
        let k = privateKey.drbgRFC6979(message: message, hashFunction: SHA256())

        XCTAssertEqual(expected.k, k.asHexString(uppercased: false), "Must produce matching k nonce.", line: line)

        let signatureFromMessage = AnyKeySigner<ECDSA<C>>.sign(message, using: keyPair)

        XCTAssertTrue(AnyKeySigner<ECDSA<C>>.verify(message, wasSignedBy: signatureFromMessage, publicKey: publicKey), line: line)

        if let expectedRHex = expected.r {
            XCTAssertEqual(expectedRHex, signatureFromMessage.r.asHexString(uppercased: false), "Must produce matching signature.R.", line: line)
        }
        if let expectedSHex = expected.s {
            XCTAssertEqual(expectedSHex, signatureFromMessage.s.asHexString(uppercased: false), "Must produce matching signature.S.", line: line)
        }

        if let expectedDER = expected.der {
            XCTAssertEqual(expectedDER, signatureFromMessage.toDER(), "Expected (DER format): \(expectedDER)", line: line)
        }
    }

    func verifyRFC6979UsingSignatureComponents<C: EllipticCurve>(
        curve: C.Type,
        key privateKeyHex: String,
        message messageToHash: String,
        expected: (k: String, r: String, s: String),
        line: UInt
    ) {
        verifyRFC6979(
            curve: curve,
            key: privateKeyHex,
            message: messageToHash,
            expected: (k: expected.k, r: expected.r, s: expected.s, der: nil),
            line: line
        )
    }

    func verifyRFC6979UsingDER<C: EllipticCurve>(
        curve: C.Type,
        key privateKeyHex: String,
        message messageToHash: String,
        expected: (k: String, der: String),
        line: UInt
    ) {
        verifyRFC6979(
            curve: curve,
            key: privateKeyHex,
            message: messageToHash,
            expected: (k: expected.k, r: nil, s: nil, der: expected.der),
            line: line
        )
    }

    func verifyRFC6979WithSignature<C: EllipticCurve>(
        curve: C.Type,
        key privateKeyHex: String,
        message messageToHash: String,
        expected: (k: String, r: String, s: String, der: String),
        line: UInt = #line
    ) {
        verifyRFC6979(
            curve: curve,
            key: privateKeyHex,
            message: messageToHash,
            expected: (k: expected.k, r: expected.r, s: expected.s, der: expected.der),
            line: line
        )
    }

}

// MARK: Message init
extension Message {
    init(message: String) {
        self.init(unhashed: message, encoding: .default, hashFunction: SHA256())!
    }

    init(hex: String) {
        self.init(hashedHex: hex, hashedBy: SHA256())!
    }
}
