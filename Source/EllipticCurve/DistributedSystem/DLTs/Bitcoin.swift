//
//  Bitcoin.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Bitcoin: DistributedSystem {
    public let network: Network

    public enum Network: NetworkInformation {
        case testnet
        case mainnet

        public var pubkeyhash: Byte {
            switch self {
            case .mainnet: return 0x00
            case .testnet: return 0x6f
            }
        }

        public var privateKeyWifPrefix: Byte {
            switch self {
            case .mainnet: return 0x80
            case .testnet: return 0xef
            }
        }

        public var privateKeyWifSuffix: Byte {
            return 0x01
        }
    }

    public struct WIF: WIFFormatter {
        public typealias System = Bitcoin
    }

    public let wifFormatter = WIF()

    public init(_ network: Network) {
        self.network = network
    }
}

public extension Bitcoin {
    typealias Curve = Secp256k1

    func addressHash(of data: Data) -> Data{
        return Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(data)
    }
}
