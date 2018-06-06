//
//  EllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

// Thanks to certicom for tutorials about Elliptic Curve Cryptograph
// https://www.certicom.com/content/certicom/en/ecc.html
// https://www.certicom.com/content/certicom/en/ecc-tutorial.html

/// Elliptic Curve over the field of integers modulo a prime
/// The curve of points satisfying y^2 = x^3 + a*x + b (mod p).
public struct EllipticCurve {
    public typealias NumberType = Int

    private let p: NumberType
    private let a: NumberType
    private let b: NumberType

    public init(prime p: NumberType, a: NumberType, b: NumberType) {
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

public struct Point {
    public typealias NumberType = EllipticCurve.NumberType
    public let x: NumberType
    public let y: NumberType
    public init(x: NumberType, y: NumberType) {
        self.x = x
        self.y = y
    }
}

struct PointOnEllipticCurve {

    private let curve: EllipticCurve
    private let point: Point

    public init(curve: EllipticCurve, point: Point) {
        self.curve = curve
        self.point = point
    }
}

// https://www.johannes-bauer.com/compsci/ecc/#anchor23

//In order to turn all these mathematical basics into a cryptosystem, some parameters have to be defined that are sufficient to do meaningful operations. There are 6 distinct values for the Fp case and they comprise the so-called "domain parameters":

// `p`: The prime number which defines the field in which the curve operates `Fp`. All point operations are taken modulo `p`.

// `a`, `b`: The two coefficients which define the curve. These are integers.

// `G`: The generator or base point. A distinct point of the curve which resembles the "start" of the curve. This is either given in point form `G` or as two separate integers `gx` and `gy`

// `n`: The order of the curve generator point `G`. This is, in layman's terms, the number of different points on the curve which can be gained by multiplying a scalar with `G`. For most operations this value is not needed, but for digital signing using ECDSA the operations are congruent modulo `n`, not `p`.

// `h`: The cofactor of the curve. It is the quotient of the number of curve-points, or #E(Fp), divided by n.
func generatePrivateKeyJB() -> KeyData {

    // To get the private key, choose a random integer dA so that: 0 < dA < n


    fatalError()
}
