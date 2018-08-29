//
//  ShortWeierstraßCurve.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

///      𝑆: 𝑦² = 𝑥³ + 𝐴𝑥 + 𝐵
/// - Requires: `𝟜𝑎³ + 𝟚𝟟𝑏² ≠ 𝟘 in 𝔽_𝑝 (mod 𝑝)`
public struct ShortWeierstraßCurve: ExpressibleByAffineCoordinates, ExpressibleByProjectiveCoordinates, CustomStringConvertible {


    private let a: Number
    private let b: Number
    public let galoisField: Field
    public let equation: TwoDimensionalBalancedEquation

    public init?(
        a: Number,
        b: Number,
        galoisField: Field
        ) {

        guard Requirements.areFullfilled(a: a, b: b, over: galoisField) else { return nil }

        self.a = a
        self.b = b
        self.galoisField = galoisField
        self.equation = TwoDimensionalBalancedEquation(
            lhs: { x in
                galoisField.mod { x**3 + a*x + b }
        }, rhs: { y in
            galoisField.mod { y**2 }
        }, yFromX: { x in
            galoisField.squareRoots(of: x)
        }
        )
    }

    struct Requirements {
        static func areFullfilled(a: Number, b: Number, over field: Field) -> Bool {
            return field.mod { 4*a**3 + 27*b**2 } != 0
        }
    }

    /// Returns a list of the y-coordinates on the curve at given x.
    func getY(fromX x: Number) -> [Number] {
        return equation.getYFrom(x: x)
    }
}

// MARK: - ExpressibleByAffineCoordinates
public extension ShortWeierstraßCurve {

    static let identityPointAffine: Affine = .infinity
    static let identityPointProjective = Projective(x: 0, y: 1, z: 0)

    func isIdentity<P>(point: P) -> Bool where P: Point {
        if let affine = point as? Affine {
            return affine == identityPointAffine
        } else if let projective = point as? Projective {
            return projective == identityPointProjective
        }
        return false
    }

    func invertAffine(point: Affine) -> Affine {
        return Affine(x: point.x, y: -point.y, over: galoisField)
    }

    func addAffine(point p1: Affine, to p2: Affine) -> Affine {
        guard !(isIdentity(point: p1) && isIdentity(point: p2)) else { return identityPointAffine }
        guard !isIdentity(point: p1) else { return p2 }
        guard !isIdentity(point: p2) else { return p1 }

        guard p1 != invertAffine(point: p2) else { return identityPointAffine }

        let x1 = p1.x
        let y1 = p1.y
        let x2 = p2.x
        let y2 = p2.y

        let λ = modInverseP(y2 - y1, x2 - x1)
        let x3 = mod { λ**2 - x1 - x2 }
        let y3 = mod { λ * (x1 - x3) - y1 }
        return Affine(x: x3, y: y3, over: galoisField)
    }

    func doubleAffine(point p: Affine) -> Affine {
        guard !isIdentity(point: p) else { return identityPointAffine }

        let x = p.x
        let y = p.y

        let λ = modInverseP(3 * x**2 + a, 2 * y)

        let x2 = mod { λ**2 - 2 * x }
        let y2 = mod { λ * (x - x2) - y }

        return Affine(x: x2, y: y2, over: galoisField)
    }

}

// MARK: - ExpressibleByProjectiveCoordinates
public extension ShortWeierstraßCurve {

    func affineToProjective(_ affinePoint: Affine) -> Projective {
        guard !isIdentity(point: affinePoint) else { return identityPointProjective }
        let x = affinePoint.x
        let y = affinePoint.y
        return Projective(x: x, y: y, z: 1)
    }

    func projectiveToAffine(_ projectivePoint: Projective) -> Affine {
        guard !isIdentity(point: projectivePoint) else { return identityPointAffine }
        let X = projectivePoint.x
        let Y = projectivePoint.y
        let Z = projectivePoint.z
        let x = modInverseP(X, Z) // galoisField.divide(X, by: Z)
        let y = modInverseP(Y, Z) // galoisField.divide(Y, by: Z)
        return Affine(x: x, y: y)
    }

    /// "dbl-2007-bl", see: https://hyperelliptic.org/EFD/g1p/auto-shortw-projective-1.html
    /// directly to code: https://hyperelliptic.org/EFD/g1p/auto-code/shortw/projective-1/doubling/dbl-2007-bl.op3
    func doubleProjective(point p: Projective) -> Projective {
        guard !isIdentity(point: p) else { return identityPointProjective }
        let X1 = p.x
        let Y1 = p.y
        let Z1 = p.z

        let X3, Y3, Z3, XX, ZZ, w, s, ss, sss, R, RR, B, h: Number

        XX = X1**2
        ZZ = Z1**2
        w = a*ZZ+3*XX
        s = 2*Y1*Z1
        ss = s**2
        sss = s*ss
        R = Y1*s
        RR = R**2
        B = (X1+R)**2-XX-RR
        h = w**2-2*B
        X3 = h*s
        Y3 = w*(B-h)-2*RR
        Z3 = sss

        return Projective(x: X3, y: Y3, z: Z3, over: galoisField)
    }

    /// "add-2007-bl" see: https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-3.html
    /// directly to code: https://www.hyperelliptic.org/EFD/g1p/auto-code/edwards/projective/addition/add-2007-bl-2.op3
    func addProjective(point p1: Projective, to p2: Projective) -> Projective {
        guard !(isIdentity(point: p1) && isIdentity(point: p2)) else { return identityPointProjective }
        guard !isIdentity(point: p1) else { return p2 }
        guard !isIdentity(point: p2) else { return p1 }

        let X1 = p1.x
        let Y1 = p1.y
        let Z1 = p1.z

        let X2 = p2.x
        let Y2 = p2.y
        let Z2 = p2.z

        let U1, U2, S1, S2, ZZ, T, TT, M, R, F, L, LL, G, W, X3, Y3, Z3: Number

        U1 = X1 * Z2
        U2 = X2 * Z1
        S1 = Y1 * Z2
        S2 = Y2 * Z1
        ZZ = Z1 * Z2
        T = U1 + U2
        TT = T ** 2
        M = S1 + S2
        R = TT - U1 * U2 + a * ZZ**2
        F = ZZ * M
        L = M * F
        LL = L ** 2
        G = (T + L) ** 2 - TT - LL
        W = 2 * R**2 - G
        X3 = 2 * F * W
        Y3 = R * (G - 2 * W) - 2 * LL
        Z3 = 4 * F ** 3

        return Projective(x: X3, y: Y3, z: Z3, over: galoisField)
    }

}

// MARK: - CustomStringConvertible
public extension ShortWeierstraßCurve {
    var description: String {
        return "𝑦² = 𝑥³ + 𝐴𝑥 + 𝐵 over \(galoisField)"
    }

    var sageRepresentation: String {
        // Sage Form: y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x + a6
        return "EllipticCurve(GF(\(galoisField.modulus), [\(a), \(b)])"
    }
}

// MARK: - FUTURE When Jacobian

/// Jacobian coordinates for short Weierstrass curves
/// https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian.html
/// dbl-2007-bl
/// Three-operand-code: https://hyperelliptic.org/EFD/g1p/auto-code/shortw/jacobian/doubling/dbl-2007-bl.op3
//    public func doubleJacobianPoint(_ p: Jacobian) -> Jacobian {
//        guard p != neutralPointJacobian else { return neutralPointJacobian }
//
//        let X1 = p.x
//        let Y1 = p.y
//        let Z1 = p.z
//
//        let XX, YY, YYYY, ZZ, S, M, T, X3, Y3, Z3: Number
//
//        XX = X1**2
//        YY = Y1**2
//        YYYY = YY**2
//        ZZ = Z1**2
//        S = 2*((X1+YY)**2-XX-YYYY)
//        M = 3*XX+a*ZZ**2
//        T = M**2-2*S
//        X3 = T
//        Y3 = M*(S-T)-8*YYYY
//        Z3 = (Y1+Z1)**2-YY-ZZ
//
//        return Jacobian(X3, Y3, Z3, modulus: galoisField.modulus)
//    }
