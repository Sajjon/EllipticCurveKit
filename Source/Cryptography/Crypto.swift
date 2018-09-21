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
    static func hash(_ data: DataConvertible, function: HashFunction) -> Data {
        let bytes = CryptoSwift.SHA2(variant: function.sha2).calculate(for: data.bytes)
        return Data(bytes)
    }

    static func hmac(key: DataConvertible, data: DataConvertible, function: HashFunction) throws -> Data {
        let bytes = try CryptoSwift.HMAC(key: key.asData.bytes, variant: function.hmac).authenticate(data.asData.bytes)
        return Data(bytes)
    }

    static func ripemd160(_ data: Data, function: HashFunction) -> Data {
        return RIPEMD160.hash(message: hash(data, function: function))
    }
}

public extension Crypto {
    static func sha2Sha256_ripemd160(_ data: Data) -> Data {
        return ripemd160(data, function: .sha256)
    }

    static func sha2Sha256(_ data: Data) -> Data {
        return hash(data, function: .sha256)
    }

    static func sha2Sha256_twice(_ data: Data) -> Data {
        return sha2Sha256(sha2Sha256(data))
    }

    static func hmacSha256(key: DataConvertible, data: DataConvertible) throws -> Data {
        return try hmac(key: key, data: data, function: .sha256)
    }
}


extension HashFunction {
    fileprivate var hmac: CryptoSwift.HMAC.Variant {
        switch self {
        case .sha256: return CryptoSwift.HMAC.Variant.sha256
        }
    }

    fileprivate var sha2: CryptoSwift.SHA2.Variant {
        switch self {
        case .sha256: return CryptoSwift.SHA2.Variant.sha256
        }
    }
}

