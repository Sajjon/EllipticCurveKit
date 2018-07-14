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
    associatedtype CurveType: EllipticCurve

    /// Generates a new key pair (PrivateKey and PublicKey)
    static func generateNewKeyPair() -> KeyPairType

    /// Support Wallet Import Format (a.k.a. WIF)
    static func restoreKeyPairFrom(privateKey: PrivateKeyType) -> KeyPairType

    /// A `Wallet` is a `KeyPair` and with `PublicAddresses` derived (compressed/uncompressed)
    static func createWallet(using keyPair: KeyPairType) -> WalletType
}

public extension EllipticCurveCryptographyKeyGeneration {
    public typealias PrivateKeyType = PrivateKey<CurveType>
    public typealias KeyPairType = KeyPair<CurveType>
    public typealias WalletType = Wallet<CurveType>
}

public protocol EllipticCurveCryptographySigning {
    /// Which method to use for signing, e.g. `Schnorr`
    associatedtype SigningMethodUsed: Signing

    /// Signs `message` using `keyPair`
    static func sign(_ message: Message, using keyPair: KeyPairType) -> SignatureType

    /// Checks if `signature` is valid for `message` or not.
    static func verify(_ message: Message, wasSignedBy signature: SignatureType, publicKey: PublicKeyType) -> Bool
}

public extension EllipticCurveCryptographySigning {
    public typealias CurveType = SigningMethodUsed.CurveType
    public typealias KeyPairType = KeyPair<CurveType>
    public typealias PublicKeyType = PublicKey<CurveType>
    public typealias SignatureType = Signature<CurveType>
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

public struct AnyKeySigner<SigningMethod: Signing>: EllipticCurveCryptographySigning {}
public extension AnyKeySigner {


    static func sign(_ message: Message, using keyPair: KeyPairType) -> SignatureType {
        return CurveType.sign(message: message, keyPair: keyPair)
    }

    static func verify(_ message: Message, wasSignedBy signature: SignatureType, publicKey: PublicKeyType) -> Bool {
        return CurveType.verify(message, wasSignedBy: signature, publicKey: publicKey)
    }
}

public extension AnyKeySigner {
    typealias SigningMethodUsed = SigningMethod
    typealias CurveType = SigningMethodUsed.CurveType
    typealias KeyPairType = KeyPair<CurveType>
    typealias PublicKeyType = PublicKey<CurveType>
    typealias SignatureType = Signature<CurveType>
}
