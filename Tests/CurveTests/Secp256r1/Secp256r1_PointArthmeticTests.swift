//
//  Secp256r1_PointArthmeticTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

import XCTest
import BigInt

@testable import EllipticCurveKit

class Secp256r1_PointArthmeticTests: XCTestCase {

    /// Private Key WIF example from http://docs.neo.org/en-us/utility/sdk/common.html
    func testSecp256r1TestVector1() {
        let privateKey = PrivateKey<Secp256r1>(hex: "0x3D40F190DA0C18E94DB98EC34305113AAE7C51B51B6570A8FDDAA3A981CD69C3")!
        let privateKeyWIF = PrivateKeyWIF(privateKey: privateKey, system: Neo(.mainnet))


        XCTAssertEqual(privateKeyWIF.compressed, "KyGnCKKnL1xCZ8V2bo8vZvTpVrwAGnAXTmRqBEwA5JG2mqdgfgSx")

        let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)
        XCTAssertEqual(publicKey.hex.compressed, "03ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D")
        XCTAssertEqual(publicKey.hex.uncompressed, "04ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D3E13BE2FFCB19403A761420B1D26AF55E265A6F924FE0B7174D4D3654249092F")


        XCTAssertEqual(publicKey.point.x.asHexStringLength64(), "ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D")

        XCTAssertEqual(publicKey.point.y.asHexStringLength64(), "3E13BE2FFCB19403A761420B1D26AF55E265A6F924FE0B7174D4D3654249092F")

        let neoPublicAddress = "AbRbkor1bsuxCuhAQeXHuN4gGXJJwfNApS"

    }

    /// Some uninteresting private key generated using https://neotracker.io/wallet
    func testSecp256r1TestVector2() {
        let privateKey = PrivateKey<Secp256r1>(hex: "0x1D6DAF1F253F4568030E70108826E729662407EEF24D10F98ACA7B0F24843115")!
        let privateKeyWIF = PrivateKeyWIF(privateKey: privateKey, system: Neo(.mainnet))


        XCTAssertEqual(privateKeyWIF.compressed, "KxCv5WKisEr8ELERwA3BSrAGH8hMwze5hEoCSveGcaz52UekU128")

        let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)
        XCTAssertEqual(publicKey.hex.compressed, "02B14C55CE9E942E7439171EBDFFBCFFE8ED0C933475AEC792B0D48EC1829EA206")
        XCTAssertEqual(publicKey.hex.uncompressed, "04B14C55CE9E942E7439171EBDFFBCFFE8ED0C933475AEC792B0D48EC1829EA2065598091915EFFA6F181D3EC8B4374806247081684C822D622DDE241288B9F0B4")

        XCTAssertEqual(publicKey.point.x.asHexStringLength64(), "B14C55CE9E942E7439171EBDFFBCFFE8ED0C933475AEC792B0D48EC1829EA206")

        XCTAssertEqual(publicKey.point.y.asHexStringLength64(), "5598091915EFFA6F181D3EC8B4374806247081684C822D622DDE241288B9F0B4")

        let neoPublicAddress = "AeGbQr4SuU1oXhxMDJqu9U5UNj5gPc6kNk"

    }

    /// Some uninteresting private key generated using https://neotracker.io/wallet
    func testSecp256r1TestVector3() {
        let privateKey = PrivateKey<Secp256r1>(hex: "0x7D7DC5F71EB29DDAF80D6214632EEAE03D9058AF1FB6D22ED80BADB62BC1A534")!
        let privateKeyWIF = PrivateKeyWIF(privateKey: privateKey, system: Neo(.mainnet))


        XCTAssertEqual(privateKeyWIF.compressed, "L1RedRJLmYY3Ck2ozMYfeWjAMgxfXKvqEyfNpdMdggFi4P4XKFoA")

        let publicKey = PublicKey<Secp256r1>(privateKey: privateKey)

        XCTAssertEqual(publicKey.hex.compressed, "03EAD218590119E8876B29146FF89CA61770C4EDBBF97D38CE385ED281D8A6B230")
        XCTAssertEqual(publicKey.hex.uncompressed, "04EAD218590119E8876B29146FF89CA61770C4EDBBF97D38CE385ED281D8A6B23028AF61281FD35E2FA7002523ACC85A429CB06EE6648325389F59EDFCE1405141")

        XCTAssertEqual(publicKey.point.x.asHexStringLength64(), "EAD218590119E8876B29146FF89CA61770C4EDBBF97D38CE385ED281D8A6B230")

        XCTAssertEqual(publicKey.point.y.asHexStringLength64(), "28AF61281FD35E2FA7002523ACC85A429CB06EE6648325389F59EDFCE1405141")

        let neoPublicAddress = "Ac3TQZXhJpZY6VAdKdJEewEyQi4xD2xAQt"

    }
}
