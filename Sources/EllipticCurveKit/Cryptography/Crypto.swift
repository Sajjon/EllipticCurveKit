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
//import CryptoSwift
import CryptoKit


public struct Crypto {}
public extension Crypto {
    static func hash<H>(_ data: DataConvertible, function: H) -> Data where H: HashFunction {
        var hasher = function
        hasher.update(data: data.asData)
        return Data(hasher.finalize())
    }

    static func hmac<H>(key: DataConvertible, data: DataConvertible, function: H) throws -> Data where H: HashFunction {
//        let bytes = try CryptoSwift.HMAC(key: key.asData.bytes, variant: function.hmac).authenticate(data.asData.bytes)
//        return Data(bytes)
        
//        fatalError()
//        switch function {
//        case .sha256:
            var hmac = HMAC<H>.init(key: SymmetricKey.init(data: key.asData))
            hmac.update(data: data.asData)
            return Data(hmac.finalize())
        
    }

    static func ripemd160<H>(_ data: Data, function: H) -> Data where H: HashFunction {
        return RIPEMD160.hash(message: hash(data, function: function))
    }
}

public extension Crypto {
    static func sha2Sha256_ripemd160(_ data: Data) -> Data {
        return ripemd160(data, function: SHA256())
    }

    static func sha2Sha256(_ data: Data) -> Data {
        return hash(data, function: SHA256())
    }

    static func sha2Sha256_twice(_ data: Data) -> Data {
        return sha2Sha256(sha2Sha256(data))
    }

    static func hmacSha256(key: DataConvertible, data: DataConvertible) throws -> Data {
        return try hmac(key: key, data: data, function: SHA256())
    }
}

extension Data {
    func sha256() -> Data {
        bytes.sha256()
    }
}

extension Array where Element == Byte {
    func sha256() -> Data {
        var sha = SHA256()
        sha.update(data: self)
        return Data(sha.finalize())
    }
}


//extension HashFunction {
//    fileprivate var hmac: CryptoSwift.HMAC.Variant {
////        switch self {
////        case .sha256: return CryptoSwift.HMAC.Variant.sha256
////        }
//        
//        fatalError()
//    }
//
//    fileprivate var sha2: CryptoSwift.SHA2.Variant {
////        switch self {
////        case .sha256: return CryptoSwift.SHA2.Variant.sha256
////        }
//        
//        fatalError()
//    }
//}

