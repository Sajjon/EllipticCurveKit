//
//  Secp256k1.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// The curve E: `y² = x³ + ax + b` over Fp
/// `secp256r1` Also known as the `Bitcoin curve` (though used by Ethereum, Zilliqa, Radix)
public struct Secp256k1: EllipticCurve {

    /// `2^256 −2^32 −2^9 −2^8 −2^7 −2^6 −2^4 − 1` <=> `2^256 - 2^32 - 977`
    public static let P = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!

    public static let a = Number(0)
    public static let b = Number(7)
    public static let G = Point(
        x: Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!,
        y: Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
    )

    public static let N = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
    public static let h = Number(1)
    public static let name = CurveName.secp256k1
}

