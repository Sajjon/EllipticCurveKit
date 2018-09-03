//
//  ExpressibleByProjectiveCoordinates.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol ExpressibleByProjectiveCoordinates: CurveForm {
    typealias Projective = ProjectivePointOnCurve<Self>
    static var identityPointProjective: Projective { get }

    func addProjective(point p1: Projective, to p2: Projective) -> Projective
    func doubleProjective(point: Projective) -> Projective
    func multiplyProjective(point: Projective, by number: Number) -> Projective

    func affineToProjective(_ affinePoint: AffinePointOnCurve<Self>) -> Projective
    func projectiveToAffine(_ projectivePoint: Projective) -> AffinePointOnCurve<Self>
}

public extension ExpressibleByProjectiveCoordinates {
    var identityPointProjective: ProjectivePointOnCurve<Self> {
        return Self.identityPointProjective
    }
}

public extension ExpressibleByProjectiveCoordinates {

     func multiplyProjective(point: Projective, by number: Number) -> Projective {
        var r = identityPointProjective
        var P = point

        func addition(_ p1: Projective, _ p2: Projective) -> Projective {
            guard !(isIdentity(point: p1) && isIdentity(point: p2)) else { return identityPointProjective }
            guard !isIdentity(point: p1) else { return p2 }
            guard !isIdentity(point: p2) else { return p1 }
            if p1 == p2 {
                return doubleProjective(point: p1)
            } else {
                return addProjective(point: p1, to: p2)
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
