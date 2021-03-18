//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import CryptoKit

public protocol SymmetricKeyDerivationFunction {
    func derive(
        ephemeralPublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>,
        whitePublicKey: PublicKey<Secp256k1>
    ) -> CryptoKit.SymmetricKey
}
