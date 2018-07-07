//
//  PrivateKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

public struct PrivateKey {
    public let randomBigNumber: Number
    public let curve: AnyEllipticCurveOverFiniteField

    public init?<C>(randomBigNumber: Number, on curve: C) where C: EllipticCurveOverFiniteField {
        guard randomBigNumber < curve.order else { print("Failed to create PrivateKey, `randomBigNumber` = `\(randomBigNumber)` is bigger than Curve.Order = `\(curve.order)`");return nil }
        self.randomBigNumber = randomBigNumber
        self.curve = AnyEllipticCurveOverFiniteField(curve: curve)
    }
}

public extension PrivateKey {
    static func * <C>(lhs: C, rhs: PrivateKey) -> C where C: EllipticCurveOverFiniteField {
        return lhs * rhs.randomBigNumber
    }
}

public extension PrivateKey {
    init<C>(on curve: C) where C: EllipticCurveOverFiniteField {
        var privateKey: PrivateKey?
        while privateKey == nil {
            privateKey = PrivateKey(randomBigNumber: BigInt(sign: .plus, magnitude: BigUInt.randomInteger(withMaximumWidth: 256)), on: curve)
        }
        self = privateKey!
    }

    init?<C>(hexString: String, on curve: C) where C: EllipticCurveOverFiniteField {
        guard let bigNumber = Number(hexString: hexString) else { print("Failed to create number from hexstring");return nil }
        self.init(randomBigNumber: bigNumber, on: curve)
    }
}

//extension PrivateKey: ExpressibleByStringLiteral {}
//public extension PrivateKey {
//    /// Assumes HEXADECIMAL string
//    init(stringLiteral value: String) {
//        guard let fromString = PrivateKey(hexString: value) else { fatalError("String not convertible to PrivateKey") }
//        self = fromString
//    }
//}

public extension PrivateKey {
    func toHexString() -> String {
        return randomBigNumber.asHexString()
    }
}

extension PrivateKey: CustomStringConvertible {
    public var description: String {
        return toHexString()
    }
}

//# WIF stands for "Wallet Import Format"
//# In Bitcoin the WIFs begins with a leading char according to this formula
//# BTC WIF MAINNET
//## uncompressed: `5`
//## compressed: `K`
//# BTC WIF TESTNET
//## uncompressed: `9`
//## compressed: `L`
//## WIF https://en.bitcoin.it/wiki/Wallet_import_format
//## compressed WIF http://sourceforge.net/mailarchive/forum.php?thread_name=CAPg%2BsBhDFCjAn1tRRQhaudtqwsh4vcVbxzm%2BAA2OuFxN71fwUA%40mail.gmail.com&forum_name=bitcoin-development

public struct PrivateKeyWIF {}
