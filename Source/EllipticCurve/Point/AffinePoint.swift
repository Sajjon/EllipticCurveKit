//
//  Point.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation


public struct AffinePoint<CurveType: EllipticCurve>: EllipticCurvePoint {
    public typealias Curve = CurveType
    public let x: Number
    public let y: Number

    public init(x: Number, y: Number) {
        precondition(x >= 0, "Coordinates should have non negative values, x was negative: `\(x)`")
        precondition(y >= 0, "Coordinates should have non negative values, y was negative: `\(y)`")
        self.x = x
        self.y = y
    }
}

// EllipticCurvePoint
public extension AffinePoint {

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Addition of points refers to the usual elliptic curve group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve#The_group_law
    static func addition(_ p1: AffinePoint?, _ p2: AffinePoint?) -> AffinePoint? {
        return addition_v2(p1, p2)
    }

    static func addition_v1(_ p1: AffinePoint?, _ p2: AffinePoint?) -> AffinePoint? {
        guard let p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        let P = Curve.P

        let λ = modP {
            if p1 == p2 {
                return (3 * (p1.x * p1.x) + Curve.a) * (2 * p1.y).power(P - 2, modulus: P)
            } else {
                return (p2.y - p1.y) * (p2.x - p1.x).power(P - 2, modulus: P)
            }
        }
        let x3 = modP { λ * λ - p1.x - p2.x }
        let y3 =  modP { λ * (p1.x - x3) - p1.y }

        return AffinePoint(x: x3, y: y3)
    }

    static func addition_v2(_ p1: AffinePoint?, _ p2: AffinePoint?) -> AffinePoint? {
        guard let p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        if p1 == p2 {
            /// or `p2`, irrelevant since they equal each other
            return doublePoint(p1)
        } else {
            return addPoint(p1, to: p2)
        }
    }

    private static func addPoint(_ p1: AffinePoint, to p2: AffinePoint) -> AffinePoint {
        precondition(p1 != p2)
        let λ = modInverseP(p2.y - p1.y, p2.x - p1.x)
        let x3 = modP { λ * λ - p1.x - p2.x }
        let y3 = modP { λ * (p1.x - x3) - p1.y }
        return AffinePoint(x: x3, y: y3)
    }

    private static func doublePoint(_ p: AffinePoint) -> AffinePoint {
        let λ = modInverseP(3 * (p.x * p.x) + Curve.a, 2 * p.y)

        let x3 = modP { λ * λ - 2 * p.x }
        let y3 = modP { λ * (p.x - x3) - p.y }

        return AffinePoint(x: x3, y: y3)
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Multiplication of an integer and a point refers to the repeated application of the group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
    static func * (point: AffinePoint, number: Number) -> AffinePoint {
        var P: AffinePoint? = point
        var n = number
        var r: AffinePoint!
        for i in 0..<n.magnitude.bitWidth {
            if n.magnitude[bitAt: i] {
                r = addition(r, P)
            }
            P = addition(P, P)
        }
        return r
    }

}
