//
//  EllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

public typealias Number = BigUInt

// Thanks to certicom for tutorials about Elliptic Curve Cryptograph
// https://www.certicom.com/content/certicom/en/ecc.html
// https://www.certicom.com/content/certicom/en/ecc-tutorial.html

/// Elliptic Curve over the field of integers modulo a prime
/// The curve of points satisfying y^2 = x^3 + a*x + b (mod p).
public struct EllipticCurve {

    public enum Name {
        case secp256k1
        case p384
    }

    private let p: Number
    private let a: Number
    private let b: Number

    public init(name: String, field: Field, prime p: Number, a: Number, b: Number) {
        self.p = p
        self.a = a
        self.b = b
    }
}

public extension EllipticCurve {
    func containsPoint(_ point: Point) -> Bool {
        fatalError()
    }
}

public extension EllipticCurve {
    static var zilliqa: EllipticCurve {
        return EllipticCurve(name: <#T##String#>, field: <#T##Field#>, prime: <#T##Number#>, a: <#T##Number#>, b: <#T##Number#>)
    }
}

# Certicom secp256-k1
_a = 0x0000000000000000000000000000000000000000000000000000000000000000
_b = 0x0000000000000000000000000000000000000000000000000000000000000007
_p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
_Gx = 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
_Gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8
_r = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

curve_secp256k1 = ellipticcurve.CurveFp(_p, _a, _b)
generator_secp256k1 = ellipticcurve.Point(curve_secp256k1, _Gx, _Gy, _r)

