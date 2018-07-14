//
//  KeyPair.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyPair<Curve: EllipticCurve> {
    public typealias PrivateKeyType = PrivateKey<Curve>
    public typealias PublicKeyType = PublicKey<Curve>

    let privateKey: PrivateKeyType
    let publicKey: PublicKeyType

    public init(`private`: PrivateKeyType, `public`: PublicKeyType) {
        self.privateKey = `private`
        self.publicKey = `public`
    }
}

