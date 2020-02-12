//
//  Neo.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Neo: DistributedSystem {

    public typealias Curve = Secp256r1
    // TODO support Neo public address formatting
    public typealias Network = Bitcoin.Network
    public let network: Network
    public struct WIF: WIFFormatter {
        public typealias System = Neo
    }

    public let wifFormatter = WIF()
    public init(_ network: Network) {
        self.network = network
    }
}
