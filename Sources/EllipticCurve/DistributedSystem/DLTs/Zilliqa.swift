//
//  Zilliqa.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Zilliqa: DistributedSystem {
    public typealias Network = Bitcoin.Network
    public let network: Network
    public struct WIF: WIFFormatter {
        public typealias System = Zilliqa
    }

    public let wifFormatter = WIF()
    public init(_ network: Network) {
        self.network = network
    }

}

public extension Zilliqa {
    typealias Curve = Secp256k1

    func addressHash(of data: Data) -> Data{
        let hash = Crypto.sha2Sha256(data)
        return hash.suffix(20)
    }
}
