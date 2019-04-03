//
//  Protocols.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import Security

public protocol EllipticCurveCryptographyKeyGeneration {
    /// Elliptic Curve used, e.g. `secp256k1`
    associatedtype Curve: EllipticCurve

    /// Generates a new key pair (PrivateKey and PublicKey)
    static func generateNewKeyPair() -> KeyPairType

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKeyType) -> KeyPairType

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet<S: DistributedSystem>(using keyPair: KeyPairType, for system: S) -> Wallet<S>
}

public extension EllipticCurveCryptographyKeyGeneration {
    typealias PrivateKeyType = PrivateKey<Curve>
    typealias KeyPairType = KeyPair<Curve>
}

public struct AnyKeyGenerator<Curve: EllipticCurve>: EllipticCurveCryptographyKeyGeneration {}
public extension AnyKeyGenerator {

    static func generateNewKeyPair() -> KeyPairType {
        let privateKey = PrivateKeyType()
        return KeyPairType(private: privateKey)
    }

    static func restoreKeyPairFrom(privateKey: PrivateKeyType) -> KeyPairType {
        return KeyPairType(private: privateKey)
    }

    static func createWallet<S: DistributedSystem>(using keyPair: KeyPairType, for system: S) -> Wallet<S> {
        fatalError()
    }
}

public extension AnyKeyGenerator {
    typealias KeyPairType = KeyPair<Curve>
    typealias PrivateKeyType = PrivateKey<Curve>
    typealias PublicKeyType = PublicKey<Curve>
}
