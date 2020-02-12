//
//  Address.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Address {
    associatedtype System: DistributedSystem
    var uncompressedHash: Data { get }
    var compressedHash: Data { get }

    // primary address used, for bitcoin base58 compressed, for Zilliqa hexstring of compressedHash.
    var address: String { get }
}

public extension Address {
    var address: String {
        return base58.compressed.value
    }
}

public extension Address where System == Zilliqa {
    var address: String {
        return compressedHash.toNumber().asHexString()
    }
}


private func base58Encode(_ hash: Data) -> Base58String {
    let checksum = Crypto.sha2Sha256_twice(hash).prefix(4)
    let address = Base58String(data: hash + checksum)
    return address
}

public extension Address {
    func base58Encoded(compressed: Bool) -> Base58String {
        let data = compressed ? compressedHash : uncompressedHash
        return base58Encode(data)
    }
}

public extension Address {
    var hash: (uncompressed: Data, compressed: Data) {
        return (uncompressed: uncompressedHash, compressed: compressedHash)
    }

    var base58: (uncompressed: Base58String, compressed: Base58String) {
        return (uncompressed: base58Encoded(compressed: false), compressed: base58Encoded(compressed: true))
    }
}
