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
