//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import Foundation
import CryptoKit

/// Derivation of a symmetric key using a modified Diffie-Hellman key exchange between
/// Alice, Bob and an ephemeral public key by computing:
///
///     S = aB + E
///     x = S.x
///     key = SHA256Twice(x)
///
/// This scheme is different is not vanilla DH nor vanilla ECIES KDF, but a variant
/// developed by Alexander Cyon, and presented on [Crypto StackExchange here][cyonECIES].
///
/// [cyonECIES]: https://crypto.stackexchange.com/questions/88083/modified-ecies-using-ec-point-add-with-dh-key
///
public struct ECAddDiffieHellmanKDF: SymmetricKeyDerivationFunction {
    public init() {}
    public func derive(
        ephemeralPublicKey E: PublicKey<Secp256k1>,
        blackPrivateKey a: PrivateKey<Secp256k1>,
        whitePublicKey B: PublicKey<Secp256k1>
    ) -> CryptoKit.SymmetricKey {
        let aB = a * B
        let S = aB + E
        let x = S.x
        
        let keyData = Crypto.sha2Sha256_twice(Data(hex: x.asHexString()))
        
        return .init(data: keyData)
    }
}
