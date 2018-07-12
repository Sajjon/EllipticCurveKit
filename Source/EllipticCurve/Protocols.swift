//
//  Protocols.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation


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
