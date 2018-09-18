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
        return base58.compressed
    }
}

public extension Address where System == Zilliqa {
    var address: String {
        return compressedHash.toNumber().asHexString()
    }
}


private func base58Encode(_ hash: Data) -> String {
    let checksum = Crypto.sha2Sha256_twice(hash).prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}

public extension Address {
    func base58Encoded(compressed: Bool) -> String {
        let data = compressed ? compressedHash : uncompressedHash
        return base58Encode(data)
    }
}

public extension Address {
    var hash: (uncompressed: Data, compressed: Data) {
        return (uncompressed: uncompressedHash, compressed: compressedHash)
    }

    var base58: (uncompressed: Base58Encoded, compressed: Base58Encoded) {
        return (uncompressed: base58Encoded(compressed: false), compressed: base58Encoded(compressed: true))
    }
}
