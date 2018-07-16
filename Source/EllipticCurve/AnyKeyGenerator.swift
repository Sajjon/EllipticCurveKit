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
    static func generateNewKeyPair() -> KeyPairType

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKeyType) -> KeyPairType

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet(using keyPair: KeyPairType) -> WalletType
}

public extension EllipticCurveCryptographyKeyGeneration {
    public typealias PrivateKeyType = PrivateKey<Curve>
    public typealias KeyPairType = KeyPair<Curve>
    public typealias WalletType = Wallet<Curve>
}

public struct AnyKeyGenerator<Curve: EllipticCurve>: EllipticCurveCryptographyKeyGeneration {}
public extension AnyKeyGenerator {

    static func generateNewKeyPair() -> KeyPairType {
        fatalError()
    }

    static func restoreKeyPairFrom(privateKey: PrivateKeyType) -> KeyPairType {
        let publickey = PublicKeyType(privateKey: privateKey)
        return KeyPairType(private: privateKey, public: publickey)
    }

    static func createWallet(using keyPair: KeyPairType) -> WalletType {
        fatalError()
    }
}

public extension AnyKeyGenerator {
    typealias KeyPairType = KeyPair<Curve>
    typealias PrivateKeyType = PrivateKey<Curve>
    typealias PublicKeyType = PublicKey<Curve>
    typealias WalletType = Wallet<Curve>
}
