//
//  PrivateKeyWIF.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// WIF == Wallet Import Format
public typealias Base58Encoded = String
struct PrivateKeysWIF {
    let compressed: Base58Encoded
    let uncompressed: Base58Encoded


    init(privateKey: PrivateKey, network: Network) {

        let prefixByte: Byte = network.privateKeyWifPrefix
        let prefix = Data([prefixByte])
        let suffixByte: Byte = network.privateKeyWifSuffix
        let suffix = Data([suffixByte])

        let privateKeyData = privateKey.number.asData()
        let keyWIFUncompressed = prefix + privateKeyData
        let keyWIFCompressed = prefix + privateKeyData + suffix

        let checkSumUncompressed = Crypto.sha2Sha256_twice(keyWIFUncompressed).prefix(4)
        let checkSumCompressed = Crypto.sha2Sha256_twice(keyWIFCompressed).prefix(4)

        let uncompressedData: Data = keyWIFUncompressed + checkSumUncompressed
        let compressedData: Data = keyWIFCompressed + checkSumCompressed

        self.compressed = Base58.encode(compressedData)
        self.uncompressed = Base58.encode(uncompressedData)
    }
}
