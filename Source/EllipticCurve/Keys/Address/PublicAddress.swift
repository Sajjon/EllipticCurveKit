//
//  Address.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PublicAddress<SystemType: DistributedSystem>: Address {
    public typealias System = SystemType
    public typealias Curve = System.Curve
    public typealias PublicKeyType = PublicKey<Curve>

    public let system: System
    public let uncompressedHash: Data
    public let compressedHash: Data

    public init(publicKeyPoint: PublicKeyType, system: System) {
        self.system = system
        uncompressedHash = system.uncompressedHash(from: publicKeyPoint)
        compressedHash = system.compressedHash(from: publicKeyPoint)
    }
}

public extension PublicAddress {
    public init(keyPair: KeyPair<Curve>, system: System) {
        self.init(publicKeyPoint: keyPair.publicKey, system: system)
    }

    public init(privateKey: PrivateKey<Curve>, system: System) {
        self.init(keyPair: KeyPair(private: privateKey), system: system)
    }
}
