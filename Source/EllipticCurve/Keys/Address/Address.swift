//
//  Address.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// A Bitcoin address looks like 1MsScoe2fTJoq4ZPdQgqyhgWeoNamYPevy and is derived from an elliptic curve public key
/// plus a set of network parameters.
/// A standard address is built by taking the RIPE-MD160 hash of the public key bytes, with a version prefix and a
/// checksum suffix, then encoding it textually as base58. The version prefix is used to both denote the network for
/// which the address is valid.
struct PublicAddress {
    let hash: (uncompressed: Data, compressed: Data)
    let base58: (uncompressed: Base58Encoded, compressed: Base58Encoded)
    let zilliqa: HexString
    let network: Network

    /// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    /// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    /// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    /// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    init(publicKeyPoint: PublicKeyPoint, network: Network) {


        let uncompressedData = publicKeyPoint.data.uncompressed
        let compressedData = publicKeyPoint.data.compressed

        let zilliqaData = Crypto.sha2Sha256(compressedData)
        let number = Number(data: zilliqaData)
        let zilliqaDataString = number.asHexStringLength64()
        print(zilliqaDataString)
        let zilliqaAddress = String(zilliqaDataString.suffix(40))
        print(zilliqaAddress)
        self.zilliqa = zilliqaAddress

        let uncompressedHash = Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(uncompressedData)
        let compressedHash = Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(compressedData)
        let uncompressedBase58 = publicKeyHashToAddress(uncompressedHash)
        let compressedBase58 = publicKeyHashToAddress(compressedHash)
        self.hash = (uncompressed: uncompressedData, compressed: compressedData)
        self.base58 = (uncompressed: uncompressedBase58, compressed: compressedBase58)
        self.network = network
    }
}

/// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
/// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
/// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
/// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
func publicKeyHashToAddress(_ hash: Data) -> String {
    let checksum = Crypto.sha2Sha256_twice(hash).prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}
