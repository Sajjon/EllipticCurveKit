//
//  Curve25519.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-19.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// /// The curve E: `y² = x³ + 486662x² + x` over the quadratic extension of the prime field defined by the prime number 2^255 − 19, and it uses the base point x = 9.
/// "The original Curve25519 paper defined it as a Diffie–Hellman (DH) function. Daniel J. Bernstein has since proposed that the name Curve25519 be used for the underlying curve, and the name X25519 for the DH function"
/// https://en.wikipedia.org/wiki/Curve25519
/// Montgomery Curve: y2 = x3 + 486662x2 + x
public struct Curve25519 {

}

//class WeierstraßCurve: Curve {}
//class KoblitzCurve: ShortWeierstraßCurve {}

//typealias Transformation<From: Curve, To: Curve> = (AffinePointOnCurve<From>) -> AffinePointOnCurve<To>
//typealias ToShortWeierstraßPointTransformation<From: ConvertibleToShortWeierstraß> = Transformation<From, ShortWeierstraßCurve>
//typealias ToMontgomeryPointTransformation<From: ConvertibleToMontgomery> = Transformation<From, MontgomeryCurve>
//
//protocol ConvertibleToShortWeierstraß: Curve {
//    func toShortWeierstraß() -> (ShortWeierstraßCurve, ToShortWeierstraßPointTransformation<Self>)
//}
//
//protocol ConvertibleToMontgomery: Curve {
//    func toMontgomery() -> (MontgomeryCurve, ToMontgomeryPointTransformation<Self>)
//}

//final class MontgomeryCurve: Curve {
//
//}
//
//final class EdwardsCurve: Curve, ConvertibleToMontgomery {
//    func toMontgomery() -> (MontgomeryCurve, ToMontgomeryPointTransformation<EdwardsCurve>) {
//        fatalError()
//    }
//}

//class TwistedEdwardsCurve: ShortWeierstraßCurve, ConvertibleToMontgomery {
//    func toMontgomery() -> MontgomeryCurve {
//        fatalError()
//    }
//}

