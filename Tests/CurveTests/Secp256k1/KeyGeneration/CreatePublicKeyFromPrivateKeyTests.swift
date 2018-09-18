//
//  CreatePublicKeyFromPrivateKeyTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticCurveKit

// This is a completely uninteresting private key for a wallet with no funds.
private let privateKeyHex = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"

class CreatePublicKeyFromPrivateKeyTests: XCTestCase {

    private let privateKey = PrivateKey<Secp256k1>(hex: privateKeyHex)!

    private lazy var publicKey = PublicKey<Secp256k1>(privateKey: privateKey)

    func testCreatingPublicKeyAndAddressesFromPrivateKey() {
        XCTAssertEqual(publicKey.x.asHexString(), "F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.y.asHexString(), "B8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        XCTAssertEqual(publicKey.hex.compressed, "02F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F")
        XCTAssertEqual(publicKey.hex.uncompressed, "04F979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4FB8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184")

        let testnetAddress = PublicAddress(publicKeyPoint: publicKey, system: Bitcoin(.testnet))

        XCTAssertEqual(testnetAddress.base58.uncompressed, "mjdhN2LKkATnmK2bbNQTtcvyxtCyUcPDLY")
        XCTAssertEqual(testnetAddress.base58.compressed, "mtDqt5jYQ5P5vsT6X78B8JmrArV6fM7YjU")

        let zilliqaTestnetAddress = PublicAddress(publicKeyPoint: publicKey, system: Zilliqa(.testnet))
        XCTAssertEqual(zilliqaTestnetAddress.address, "59BB614648F828A3D6AFD7E488E358CDE177DAA0")

        let mainnetAddress = PublicAddress(publicKeyPoint: publicKey, system: Bitcoin(.mainnet))

        XCTAssertEqual(mainnetAddress.base58.uncompressed, "157k4yFLw92XzCYysoS64hif6tcGdDULm6")
        XCTAssertEqual(mainnetAddress.base58.compressed, "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU")

        let expectedMainnetPrivateKeyWIFUncompressed = "5J8kgEmHqTH9VYLd34DP6uGVmwbDXnQFQwDvZndVP4enBqz2GuM"
        let expectedMainnetPrivateKeyWIFCompressed = "KxdDnBkVJrzGUyKc45BeZ3hQ1Mx2JsPcceL3RiQ4GP7kSTX682Jj"

        let mainnetWifs = PrivateKeyWIF(privateKey: privateKey, system: Bitcoin(.mainnet))
        XCTAssertEqual(mainnetWifs.uncompressed, expectedMainnetPrivateKeyWIFUncompressed)
        XCTAssertEqual(mainnetWifs.compressed, expectedMainnetPrivateKeyWIFCompressed)

        let expectedTestnetPrivateKeyWIFUncompressed = "91uPFyaqRgMHTbqufQ7HyVpTRbwvgwwSkt5seQyzioPpxsz2QXA"
        let expectedTestnetPrivateKeyWIFCompressed = "cNzDF6kLjvgXeQnsSUzmvNCTdbFRyKVJggUWY8rZmVmkhCdFnSS9"

        let testnetWifs = PrivateKeyWIF(privateKey: privateKey, system: Bitcoin(.testnet))
        XCTAssertEqual(testnetWifs.uncompressed, expectedTestnetPrivateKeyWIFUncompressed)
        XCTAssertEqual(testnetWifs.compressed, expectedTestnetPrivateKeyWIFCompressed)

    }
}
