//
//  ExpressibleByAffineCoordinates.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol ExpressibleByAffineCoordinates: Curve {
    typealias Affine = AffinePointOnCurve<Self>

    static var identityPointAffine: Affine { get }
//    func isIdentity<P>(point: P) -> Bool where P: Point

    func addAffine(point p1: Affine, to p2: Affine) -> Affine
    func doubleAffine(point: Affine) -> Affine
    func invertAffine(point: Affine) -> Affine
    func multiplyAffine(point: Affine, by number: Number) -> Affine
}

public extension ExpressibleByAffineCoordinates {
    func multiply(point: TwoDimensionalPoint, by number: Number) -> TwoDimensionalPoint {
        return multiplyAffine(point: Affine(point: point), by: number)
    }
}

public extension ExpressibleByAffineCoordinates {

    var identityPointAffine: AffinePointOnCurve<Self> {
        return Self.identityPointAffine
    }

    func multiplyAffine(point: Affine, by number: Number) -> Affine {
        var r = identityPointAffine
        var P = point

        func addition(_ p1: Affine, _ p2: Affine) -> Affine {
            guard !isIdentity(point: p1) else { return p2 }
            guard !isIdentity(point: p2) else { return p1 }
            guard p1 != invertAffine(point: p2) else { return identityPointAffine }
            if p1 == p2 {
                return doubleAffine(point: p1)
            } else {
                return addAffine(point: p1, to: p2)
            }
        }

        for i in 0..<number.bitWidth {
            if number.magnitude[bitAt: i] {
                r = addition(r, P)
            }
            P = addition(P, P)
        }
        return r
    }
}
