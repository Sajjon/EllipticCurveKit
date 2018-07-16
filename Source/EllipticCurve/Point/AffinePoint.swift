//
//  Point.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct AffinePoint<CurveType: EllipticCurve>: EllipticCurvePoint {
    public typealias Curve = CurveType
    public let x: Number
    public let y: Number

    public lazy var ax: Number = {
        return Curve.a * x
    }()

    public lazy var y²: Number = {
        return squareModP(y)
    }()

    public lazy var x²: Number = {
        return squareModP(x)
    }()

    public lazy var x³: Number = {
        return cubeModP(x)
    }()

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
        guard var p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        let P = Curve.P

        let λ = modP {
            if p1 == p2 {
                return 3 * p1.x² * powModP(2 * p1.y, P - 2)
            } else {
                return (p2.y - p1.y) * powModP(p2.x - p1.x, P - 2)
            }
        }
        let λ² = squareModP(λ)
        let x3 = modP { λ² - p1.x - p2.x }
        let y =  modP { λ * (p1.x - x3) - p1.y }

        return AffinePoint(x: x3, y: y)
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Multiplication of an integer and a point refers to the repeated application of the group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
    static func * (point: AffinePoint, number: Number) -> AffinePoint {
        var P: AffinePoint? = point
        var n = number
        var r: AffinePoint!
        for i in 0..<256 { // n.bitWidth
            if n.magnitude[bitAt: i] {
                r = addition(r, P)
            }
            P = addition(P, P)
        }
        return r
    }

}
