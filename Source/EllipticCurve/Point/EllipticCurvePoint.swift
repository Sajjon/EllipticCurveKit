//
//  EllipticCurvePoint.swift
//  EllipticCurveKit
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

    static func modInverseP(_ v: Number, _ w: Number) -> Number {
        return Curve.modInverseP(v, w)
    }

    func modInverseP(_ v: Number, _ w: Number) -> Number {
        return Self.modInverseP(v, w)
    }

    static func modInverseN(_ v: Number, _ w: Number) -> Number {
        return Curve.modInverseN(v, w)
    }

    func modInverseN(_ v: Number, _ w: Number) -> Number {
        return Self.modInverseN(v, w)
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
        let a = Curve.a
        let b = Curve.b
        let x = self.x
        let y = self.y

        let y² = modP { y * y }
        let x³ = modP { x * x * x }
        let ax = modP { a * x }

        return modP { y² - x³ - ax } == b
    }
}
