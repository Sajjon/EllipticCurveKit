//
//  WIFFormatter.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-24.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol WIFFormatter {
    associatedtype System: DistributedSystem
    func uncompressed(from privateKey: PrivateKeyType, for network: System.Network) -> Base58String
    func compressed(from privateKey: PrivateKeyType, for network: System.Network) -> Base58String
    func base58Encode(prefix prefixByte: Byte, data: Data, suffix suffixByte: Byte?) -> Base58String
}

public extension WIFFormatter {
    typealias Curve = System.Curve
    typealias PrivateKeyType = PrivateKey<Curve>
}

public extension WIFFormatter {
    func uncompressed(from privateKey: PrivateKeyType, for network: System.Network) -> Base58String {
        return base58Encode(prefix: network.privateKeyWifPrefix, data: privateKey.number.as256bitLongData(), suffix: nil)
    }
    func compressed(from privateKey: PrivateKeyType, for network: System.Network) -> Base58String {
        return base58Encode(prefix: network.privateKeyWifPrefix, data: privateKey.number.as256bitLongData(), suffix: network.privateKeyWifSuffix)
    }

    func base58Encode(prefix prefixByte: Byte, data: Data, suffix suffixByte: Byte?) -> Base58String {
        let prefix = Data([prefixByte])
        var suffix: Data?
        if let suffixByte = suffixByte {
            suffix = Data([suffixByte])
        }

        let privateKeyData = data
        var payload = prefix + privateKeyData
        if let suffix = suffix {
            payload = payload + suffix
        }

        let checkSum = Crypto.sha2Sha256_twice(payload).prefix(4)

        let checkSummedPayload: Data = payload + checkSum

        return Base58String(data: checkSummedPayload)
    }
}
