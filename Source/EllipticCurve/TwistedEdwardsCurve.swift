//
//  TwistedEdwardsCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

///      𝐸: 𝑎𝑥² + 𝑦² = 𝟙 + 𝑑x²𝑦²
/// - Requires: `𝑎𝑑(𝑎−𝑑) ≠ 0`
public struct TwistedEdwardsCurve: ExpressibleByAffineCoordinates, ExpressibleByProjectiveCoordinates , OverGaloisField, CustomStringConvertible {

    public let equation: TwoDimensionalImbalancedEquation
    public let order: Number
    public let curveId: SpecificCurve
    public let a: Number
    public let d: Number
    public let galoisField: Field

    public var generator: TwoDimensionalPoint
    public let cofactor: Number

    struct Requirements {
        static func areFullfilled(a: Number, d: Number, over field: Field) -> Bool {
            return field.mod { a*d * (a-d) } != 0
        }
    }

    init?(
        a: Number,
        d: Number,
        galoisField field: Field,
        generator: TwoDimensionalPoint,
        cofactor: Number,
        order: Number,
        curveId: SpecificCurve,
        equation: TwoDimensionalImbalancedEquation
        ) {

        guard Requirements.areFullfilled(a: a, d: d, over: field) else { return nil }

        self.a = a
        self.d = d
        self.generator = generator
        self.cofactor = cofactor
        self.galoisField = field
        self.order = order
        self.curveId = curveId
        self.equation = equation
    }

    init?(
        a: Number,
        d: Number,
        parameters: CurveParameterExpressible,
        equation: TwoDimensionalImbalancedEquation) {
        self.init(
            a: a,
            d: d,
            galoisField: parameters.galoisField,
            generator: parameters.generator,
            cofactor: parameters.cofactor,
            order: parameters.order,
            curveId: parameters.curveId,
            equation: equation
        )
    }

    init?(
        a: Number,
        d: Number,
        parameters: CurveParameterExpressible
        ) {

        let field = parameters.galoisField

        self.init(
            a: a,
            d: d,
            parameters: parameters,
            equation: TwoDimensionalImbalancedEquation(lhs: { x, y in

                let x² = x**2
                let y² = y**2

                return field.mod { a*x² + y² }
            }, rhs: { x, y in

                let x² = x**2
                let y² = y**2

                return field.mod { 1 + d*x²*y² }
            })
        )
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


