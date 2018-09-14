//
//  KeyPair.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyPair<Curve: EllipticCurve> {
    public typealias PrivateKeyType = PrivateKey<Curve>
    public typealias PublicKeyType = PublicKey<Curve>

    public let privateKey: PrivateKeyType
    public let publicKey: PublicKeyType

    public init(`private`: PrivateKeyType, `public`: PublicKeyType) {
        self.privateKey = `private`
        self.publicKey = `public`
    }
}

public extension KeyPair {
    init(`private`: PrivateKeyType) {
        let publicKey = PublicKey(privateKey: `private`)
        self.init(private: `private`, public: publicKey)
    }

    init?(privateKeyHex: String) {
        guard let privateKey = PrivateKeyType(hex: privateKeyHex) else { return nil }
        self.init(private: privateKey)
    }
}
