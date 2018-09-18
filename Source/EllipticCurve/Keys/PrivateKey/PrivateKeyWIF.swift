//
//  PrivateKeyWIF.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// WIF == Wallet Import Format
public typealias Base58Encoded = String
public struct PrivateKeyWIF<System: DistributedSystem> {
    let compressed: Base58Encoded
    let uncompressed: Base58Encoded


    public init(privateKey: PrivateKeyType, system: System) {
        uncompressed = system.wifUncompressed(from: privateKey)
        compressed = system.wifCompressed(from: privateKey)
    }
}

public extension PrivateKeyWIF {
    typealias Curve = System.Curve
    typealias PrivateKeyType = PrivateKey<Curve>
}
