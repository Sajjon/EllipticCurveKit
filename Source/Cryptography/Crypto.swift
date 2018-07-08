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

    static func sha3Sha256(_ data: Data) -> Data {
        return data.sha3(.sha256)
    }

    static func sha2Sha256(_ data: Data) -> Data {
        return data.sha256() // this uses SHA2 not SHA1 or SHA3.
    }

    static func sha2Sha256_twice(_ data: Data) -> Data {
        return sha2Sha256(sha2Sha256(data))
    }

    static func sha3Sha256_twice(_ data: Data) -> Data {
        return sha3Sha256(sha3Sha256(data))
    }

    static func ripemd160(_ data: Data) -> Data {
        return RIPEMD160.hash(message: data)
    }

    static func sha2Sha256_ripemd160(_ data: Data) -> Data {
        return ripemd160(sha2Sha256(data))
    }
}

public extension Crypto {
    static func sha2Sha256Bytes(_ string: String) -> [Byte] {
        return string.bytes.sha256()
    }

    static func sha2Sha256(_ string: String) -> Data {
        return Data(bytes: sha2Sha256Bytes(string))
    }

    static func sha2Sha256_twice(_ string: String) -> Data {
        return Crypto.sha2Sha256(string).sha256()
    }

    static func sha3Sha256Bytes(_ string: String) -> [Byte] {
        return string.bytes.sha3(.sha256)
    }

    static func sha3Sha256(_ string: String) -> Data {
        return Data(bytes: sha3Sha256Bytes(string))
    }

//
//    static func ripemd160(_ string: String) -> Data {
//        return ripemd160(string.bytes)
//    }
//
//    static func sha256_ripemd160(_ string: String) -> Data {
//        return sha256_ripemd160(string.bytes)
//    }
}
