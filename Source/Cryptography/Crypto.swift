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

    static func sha256(_ data: Data) -> Data {
        return data.sha3(.sha256)
    }

    static func sha256_sha256(_ data: Data) -> Data {
        return sha256(sha256(data))
    }

    static func ripemd160(_ data: Data) -> Data {
        return RIPEMD160.hash(message: data)
    }

    static func sha256_ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
    }

}
