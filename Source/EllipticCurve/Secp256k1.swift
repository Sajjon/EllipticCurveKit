//
//  Curve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol EllipticCurve {}
public struct Secp256k1: EllipticCurve {}

// TODO move numbers into `EllipticCurve`
let p = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!
let n = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
let x = Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!
let y = Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
let G = Point(x: x, y: y)

public protocol EllipticCurveCryptographyKeyGeneration {

    /// Elliptic Curve used, e.g. `secp256k1`
    associatedtype Curve: EllipticCurve

    /// Generates a new key pair (PrivateKey and PublicKey)
    static func generateNewKeyPair() -> KeyPair

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKey, format: PrivateKey.Format) -> KeyPair

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet(using keyPair: KeyPair) -> Wallet
}

public protocol EllipticCurveCryptographySigning {
    /// Which method to use for signing, e.g. `Schnorr`
    associatedtype SigningMethod: Signing

    /// Signs `message` using `keyPair`
    static func sign(_ message: Message, using keyPair: KeyPair) -> Signature

    /// Checks if `signature` is valid for `message` or not.
    static func verify(_ message: Message, wasSignedBy signature: Signature, using keyPair: KeyPair) -> Bool
}

public struct AnyKeyGenerator<Curve: EllipticCurve>: EllipticCurveCryptographyKeyGeneration {}
public extension AnyKeyGenerator {
    static func generateNewKeyPair() -> KeyPair {
        fatalError()
    }

    static func restoreKeyPairFrom(privateKey: PrivateKey, format: PrivateKey.Format) -> KeyPair {
        let publickey = PublicKey(privateKey: privateKey)
        return KeyPair(private: privateKey, public: publickey)
    }

    static func createWallet(using keyPair: KeyPair) -> Wallet {
        fatalError()
    }
}

public struct AnyKeySigner<SigningType: Signing>: EllipticCurveCryptographySigning {}
public extension AnyKeySigner {
    typealias SigningMethod = SigningType

    static func sign(_ message: Message, using keyPair: KeyPair) -> Signature {
        fatalError()
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature, using keyPair: KeyPair) -> Bool {
        return schnorr_verify(message: message, publicKey: keyPair.publicKey, signature: signature)
    }
}
