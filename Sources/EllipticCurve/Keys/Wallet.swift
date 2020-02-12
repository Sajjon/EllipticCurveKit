//
//  Wallet.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Wallet<SystemType: DistributedSystem> {
    public let keyPair: KeyPairType
    public let publicAddress: PublicAddressType

    public init(keyPair: KeyPairType, publicAddress: PublicAddressType) {
        self.keyPair = keyPair
        self.publicAddress = publicAddress
    }

    public init(keyPair: KeyPairType, system: System) {
        let publicAddress = PublicAddressType(keyPair: keyPair, system: system)
        self.init(keyPair: keyPair, publicAddress: publicAddress)
    }

    public init(privateKey: KeyPairType.PrivateKeyType, system: System) {
        self.init(keyPair: KeyPairType(private: privateKey), system: system)
    }

    public init?(privateKeyHex: String, system: System) {
        guard let privateKey = KeyPairType.PrivateKeyType(hex: privateKeyHex) else { return nil }
        self.init(privateKey: privateKey, system: system)
    }
}

public extension Wallet {
    typealias System = SystemType
    typealias Curve = System.Curve
    typealias KeyPairType = KeyPair<Curve>
    typealias PublicAddressType = PublicAddress<System>
}

