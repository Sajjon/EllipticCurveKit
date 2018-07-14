//
//  EllipticCurvePoint.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

// Potential speed up of Point Artihmetic checkout: https://github.com/conz27/crypto-test-vectors/blob/master/ecc.py

public protocol EllipticCurvePoint: Equatable, CustomStringConvertible {
    associatedtype Curve: EllipticCurve
    var x: Number { get }
    var y: Number { get }

    /* `mutating get` allows for `lazy var` implementations of those variables in a struct conforming to this protocol */
    var ax: Number { mutating get }
    var y²: Number { mutating get }
    var x²: Number { mutating get }
    var x³: Number { mutating get }

    init(x: Number, y: Number)

    static func addition(_ p1: Self?, _ p2: Self?) -> Self?

    static func * (point: Self, number: Number) -> Self
}

public extension EllipticCurvePoint {
    static func modP(_ expression: @escaping () -> Number) -> Number {
        return Curve.modP(expression)
    }

    func modP(expression: @escaping () -> Number) -> Number {
        return Self.modP(expression)
    }

    static func powModP(_ base: Number, _ exponent: Number) -> Number {
        return pow(base, exponent, Curve.P)
    }

    var description: String {
        return "(x: \(x.asHexString()), y: \(x.asHexString())"
    }


    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "on_curve(point) can be implemented as `y^2 = x^3 + 7z^6 mod P`"
    ///  secp256k1: y^2 = x^3 + ax + b <=> b = y^2 - x^3 - ax
    func isOnCurve() -> Bool {
        var p = self
        let b = Curve.b
        return modP { p.y² - p.x³ - p.ax } == b
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Addition of points refers to the usual elliptic curve group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve#The_group_law
    static func addition(_ p1: Self?, _ p2: Self?) -> Self? {
        guard var p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        let P = Curve.P

        let lam = modP {
            if p1 == p2 {
                return 3 * p1.x² * powModP(2 * p1.y, P - 2) // pow(2 * p1.y, P - 2, P) //
            } else {
                return (p2.y - p1.y) * powModP(p2.x - p1.x, P - 2) // pow(p2.x - p1.x, P - 2, P)
            }
        }

        let x3 = modP { lam * lam - p1.x - p2.x }
        let y =  modP { lam * (p1.x - x3) - p1.y }

        return Self(x: x3, y: y)
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Multiplication of an integer and a point refers to the repeated application of the group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
    static func * (point: Self, number: Number) -> Self {
        var P: Self? = point
        var n = number
        var r: Self!
        for i in 0..<256 { // n.bitWidth
            if n.magnitude[bitAt: i] {
                r = addition(r, P)
            }
            P = addition(P, P)
        }
        return r
    }

}
