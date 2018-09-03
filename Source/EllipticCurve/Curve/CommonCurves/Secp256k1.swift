//
//  Secp256k1.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public let secp256k1 = Secp256k1()

/// The curve E: `𝑦² = 𝑥³ + 7` over Fp
/// `secp256k1` Also known as the `Bitcoin curve` (though used by Ethereum, Zilliqa, Radix)
public class Secp256k1: ECCBase {
    public init() {
        super.init(
            name: .named(.secp256k1),
            form: ShortWeierstraßCurve(
                a: 0,
                b: 7,
                // 2^256 −2^32 −2^9 −2^8 −2^7 −2^6 −2^4 − 1  <===>  2^256 - 2^32 - 977
                galoisField: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F"
                )!,
            order: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
            generator: AnyTwoDimensionalPoint(
                x: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
                y: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8"
            ),
            cofactor: 1
        )
    }
}



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
