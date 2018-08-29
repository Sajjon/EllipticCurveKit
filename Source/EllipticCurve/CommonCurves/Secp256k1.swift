//
//  Secp256k1.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// The curve E: `y² = x³ + ax + b` over Fp
/// `secp256k1` Also known as the `Bitcoin curve` (though used by Ethereum, Zilliqa, Radix)



//public struct Secp256k1Parameters: CurveParameterExpressible {
//
//
//    /// `2^256 −2^32 −2^9 −2^8 −2^7 −2^6 −2^4 − 1` <=> `2^256 - 2^32 - 977`
//    public let galoisField = Field(modulus: Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!)
//
//    public let a = Number(0)
//    public let b = Number(7)
//
//    public let generator: TwoDimensionalPoint = AnyTwoDimensionalPoint(
//        x: Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!,
//        y: Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
//    )
//
//    public let order = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
//    public let cofactor = Number(1)
//    public let curveId = SpecificCurve.secp256k1
//}
//
//public let secp256k1: ShortWeierstraßCurve = {
//    let param = Secp256k1Parameters()
//    return ShortWeierstraßCurve(
//        a: param.a,
//        b: param.b,
//        parameters: param
//    )!
//}()
