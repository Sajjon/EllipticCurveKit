//
//  TwistedEdwardsCurve.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import EquationKit
import BigInt

///      𝐸: 𝑎𝑥² + 𝑦² = 𝟙 + 𝑑𝑥²𝑦²
/// - Requires: `𝑎𝑑(𝑎−𝑑) ≠ 0`
public struct TwistedEdwardsCurve: CurveForm, ExpressibleByAffineCoordinates, ExpressibleByProjectiveCoordinates, CustomStringConvertible {

    public let a: Number
    public let d: Number
    public let galoisField: Field
    public let equation: Polynomial

    init?(a: Number, d: Number, galoisField field: Field) {
        let 𝑝 = field.modulus

        guard 𝑎²𝑑 - 𝑎𝑑² ≢ 𝟘 % 𝑝 ↤ [ 𝑎 ≔ a, 𝑑 ≔ d ] else { return nil }

        self.a = a
        self.d = d
        self.galoisField = field
        self.equation = EllipticCurveForm.twistedEdwards.substitute() { [ 𝑎 ≔ a, 𝑑 ≔ d ] }
    }

}

public extension TwistedEdwardsCurve {
    static let identityPointAffine = Affine(x: 0, y: 1)

    func addAffine(point p1: Affine, to p2: Affine) -> Affine {
        fatalError()
    }

    func doubleAffine(point: Affine) -> Affine {
        fatalError()
    }

    func invertAffine(point: Affine) -> Affine {
        fatalError()
    }

}

public extension TwistedEdwardsCurve {

    var description: String {
        return "TwistedEdwardsCurve 𝑎𝑥² + 𝑦² = 𝟙 + 𝑑x²𝑑𝑦²"
    }

    static var identityPointProjective: Projective {
        return Projective(x: 0, y: 1, z: 1)
    }

    func addProjective(point p1: Projective, to p2: Projective) -> Projective {
        fatalError()
    }

    func doubleProjective(point: Projective) -> Projective {
        fatalError()
    }

    func affineToProjective(_ affinePoint: Affine) -> Projective {
        fatalError()
    }

    func projectiveToAffine(_ projectivePoint: Projective) -> Affine {
        fatalError()
    }

    func isIdentity<P>(point: P) -> Bool where P : Point {
        fatalError()
    }
}


