//
//  KeyPair.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyPair {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public init(privateKey: PrivateKey, publicKeyFormat: PublicKey.Format = .uncompressed) {
        self.privateKey = privateKey
        self.publicKey = PublicKey(privateKey: privateKey, format: publicKeyFormat)
    }

    public init?<C>(randomBigNumber: Number, publicKeyFormat: PublicKey.Format = .uncompressed, on curve: C) where C: EllipticCurveOverFiniteField {
        guard let privateKey = PrivateKey(randomBigNumber: randomBigNumber, on: curve) else { return nil }
        self.init(privateKey: privateKey, publicKeyFormat: publicKeyFormat)
    }

    public init<C>(publicKeyFormat: PublicKey.Format = .uncompressed, on curve: C) where C: EllipticCurveOverFiniteField {
        self.init(privateKey: PrivateKey(on: curve), publicKeyFormat: publicKeyFormat)
    }
}

public extension KeyPair: CustomStringConvertible {
    public var description: String {
        return "PrivateKey: \(privateKey)\nPublicKey: \(publicKey)"
    }
}
