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

    static func sha2Sha256_ripemd160(_ data: Data) -> Data {
        return RIPEMD160.hash(message: sha2Sha256(data))
    }
}
