//
//  EllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol EllipticCurve { //where Point.Curve == Self {
    //    associatedtype Point: EllipticCurvePoint
    typealias Point = AffinePoint<Self>
    static var P: Number { get }
    static var a: Number { get }
    static var b: Number { get }
    static var G: Point { get }
    static var N: Number { get }
    static var h: Number { get }
}

public extension EllipticCurve {
    static func addition(_ p1: Point?, _ p2: Point?) -> Point? {
        return Point.addition(p1, p2)
    }
}

private extension EllipticCurve {
    var P: Number { return Self.P }
    var a: Number { return Self.a }
    var b: Number { return Self.b }
    var G: Point { return Self.G }
    var N: Number { return Self.N }
    var h: Number { return Self.h }
}

extension EllipticCurve {
    static func modP(_ expression: () -> Number) -> Number {
        return mod(expression(), modulus: P)
    }

    static func modN(_ expression: () -> Number) -> Number {
        return mod(expression(), modulus: N)
    }
}

public extension EllipticCurve {

    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "jacobi(point.y) can be implemented as jacobi(point.y * point.z mod P)."
    //
    /// Can be computed more efficiently using an extended GCD algorithm.
    /// reference: https://en.wikipedia.org/wiki/Jacobi_symbol#Calculating_the_Jacobi_symbol
    static func jacobi(_ point: Point) -> Number {
        func jacobi(_ number: Number) -> Number {
            let division = (P - 1).quotientAndRemainder(dividingBy: 2)
            /// pow(number, floor((P - 1) / 2), P)
            return pow(number, division.quotient, P)
        }
        return jacobi(point.y) // can be changed to jacobi(point.y * point.z % Curve.P)
    }
}
