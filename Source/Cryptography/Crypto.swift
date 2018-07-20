//
//  Crypto.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-06-30.
//
//  Inspired by: https://github.com/kishikawakatsumi/BitcoinKit/blob/master/BitcoinKit/Crypto.swift
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Crypto {}
public extension Crypto {

    static func sha2Sha256(_ data: Data) -> Data {
        return data.sha256()
    }

    static func sha2Sha256_twice(_ data: Data) -> Data {
        return sha2Sha256(sha2Sha256(data))
    }

    static func hmacSha256(key: [Byte], data: [Byte]) throws -> [Byte] {
        return try HMAC(key: key, variant: .sha256).authenticate(data)
    }

    static func sha2Sha256_ripemd160(_ data: Data) -> Data {
        return RIPEMD160.hash(message: sha2Sha256(data))
    }
}

/*
typealias Digest = Data
protocol Hashing {
    func hash(_ data: Data) -> Digest
    var digestLength: Int { get }
}

enum HashAlgorithm: Hashing {
    indirect case sha2(SHA2Variant)
    enum SHA2Variant: Hashing {
        case sha256
    }
    indirect case hmac(HMACVariant)
    enum HMACVariant: Hashing {
        case sha256
    }
}

extension HashAlgorithm {
    func hash(_ data: Data) -> Digest {
        switch self {
        case .hmac(let hmac): return hmac.hash(data)
        case .sha2(let sha2): return sha2.hash(data)
        }
    }

    var digestLength: Int {
        switch self {
        case .hmac(let hmac): return hmac.digestLength
        case .sha2(let sha2): return sha2.digestLength
        }
    }
}

extension HashAlgorithm.SHA2Variant {
    func hash(_ data: Data) -> Digest {
        fatalError()
    }

    var digestLength: Int {
        switch self {
        case .sha256: return SHA2.Variant.sha256.digestLength
        }
    }
}

extension HashAlgorithm.HMACVariant {
    func hash(_ data: Data) -> Digest {
        fatalError()
    }

    var digestLength: Int {
        switch self {
        case .sha256: return SHA2.Variant.sha256.digestLength
        }
    }
}
*/
