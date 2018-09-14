//
//  DistributedSystem.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol DistributedSystem where WIF.System == Self {
    associatedtype Curve: EllipticCurve
    associatedtype Network: NetworkInformation
    associatedtype WIF: WIFFormatter
    var network: Network { get }
    func uncompressedHash(from publicKey: PublicKey<Curve>) -> Data
    func compressedHash(from publicKey: PublicKey<Curve>) -> Data
    func addressHash(of data: Data) -> Data
    var wifFormatter: WIF { get }
}

public extension DistributedSystem {
    func uncompressedHash(from publicKey: PublicKey<Curve>) -> Data {
        return addressHash(of: publicKey.data.uncompressed)
    }

    func compressedHash(from publicKey: PublicKey<Curve>) -> Data {
        return addressHash(of: publicKey.data.compressed)
    }

    func addressHash(of data: Data) -> Data{
        return Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(data)
    }
}

public extension DistributedSystem {
    func wifUncompressed(from privateKey: PrivateKey<Curve>) -> Base58Encoded {
        return wifFormatter.uncompressed(from: privateKey, for: network)
    }
    func wifCompressed(from privateKey: PrivateKey<Curve>) -> Base58Encoded {
        return wifFormatter.compressed(from: privateKey, for: network)
    }
}
