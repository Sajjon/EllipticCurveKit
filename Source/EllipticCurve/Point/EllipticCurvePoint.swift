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

    static func squareModP(_ base: Number) -> Number {
        return powModP(base, 2)
    }

    func squareModP(_ base: Number) -> Number {
        return Self.squareModP(base)
    }

    static func cubeModP(_ base: Number) -> Number {
        return powModP(base, 3)
    }

    func cubeModP(_ base: Number) -> Number {
        return Self.cubeModP(base)
    }

    var description: String {
        return "(x: \(x.asHexString()), y: \(x.asHexString())"
    }


    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z²` and y(P) is defined as `y/z³`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "on_curve(point) can be implemented as `y² = x³ + 7z^6 mod P`"
    ///     secp256k1:
    ///     y² = x³ + ax + b
    ///     <=>
    ///     b = y² - x³ - ax
    ///     <=>
    ///     a = (x³ + b -y²)/x
    func isOnCurve() -> Bool {
        var p = self
        let b = Curve.b
        return modP { p.y² - p.x³ - p.ax } == b
    }
}
