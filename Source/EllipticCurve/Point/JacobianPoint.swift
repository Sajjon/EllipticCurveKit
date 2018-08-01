//
//  JacobianPoint.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

class Field {

    let modulus: Number

    init(modulus: Number) {
        self.modulus = modulus
    }

    func add(_ n1: Number, to n2: Number) -> Number {
        return mod(modulus) { n1 + n2 }
    }

    func subtract(_ n1: Number, from n2: Number) -> Number {
        return mod(modulus) { n1 - n2 }
    }

    func multiply(_ n1: Number, by n2: Number) -> Number {
        return mod(modulus) { n1 * n2 }
    }

    func multiplicativeInverse(of n: Number) -> Number {
        return inverse(of: n, modulus: modulus)
    }

    /// Aka reciprocal
    func divide(_ n1: Number, by n2: Number) -> Number {
        return SwiftCrypto.divide(n1, by: n2, mod: modulus)
//        return multiply(n1, by: multiplicativeInverse(of: n2))
    }

    func normalize(_ number: Number) -> Number {
        return mod(number, modulus: modulus)
    }

    func normalize(expression: () -> Number) -> Number {
        return normalize(expression())
    }
}

public protocol Curve {
    typealias Affine = AffinePointOnCurve<Self>
    typealias Projective = ProjectivePointOnCurve<Self>

    static var neutralPoint: Affine { get }
    static var neutralPointProjective: Projective { get }

    func add(_ p1: Affine, to p2: Affine) -> Affine
    func doublePoint(_ p: Affine) -> Affine

    func addProjectivePoint(_ p1: Projective, to p2: Projective) -> Projective
    func doubleProjectivePoint(_ p: Projective) -> Projective

    func invertPoint(_ p: Affine) -> Affine
}

public extension Curve {

    var neutralPoint: AffinePointOnCurve<Self> {
        return Self.neutralPoint
    }

    var neutralPointProjective: ProjectivePointOnCurve<Self> {
        return Self.neutralPointProjective
    }
}

public protocol Point: Equatable {
    var x: Number { get }
    var y: Number { get }
}
protocol ProjectivePoint: Point {
    var z: Number { get }
}
public struct AffinePointOnCurve<C: Curve>: Point {
    public let x: Number
    public let y: Number
    public let isInfinity: Bool
    public init(_ x: Number, _ y: Number, isInfinity: Bool = false) {
        self.x = x
        self.y = y
        self.isInfinity = isInfinity
    }

    static var infinity: AffinePointOnCurve<C> {
        return AffinePointOnCurve(-3, -4, isInfinity: true)
    }

    public static func == (lhs: AffinePointOnCurve<C>, rhs: AffinePointOnCurve<C>) -> Bool {
        if lhs.isInfinity && rhs.isInfinity { return true }
        if lhs.isInfinity { return false }
        if rhs.isInfinity { return false }
        return lhs.x == rhs.x && rhs.y == lhs.y
    }
}

extension AffinePointOnCurve {
    init(_ x: Number, _ y: Number, modulus p: Number) {
        self.init(
            mod(x, modulus: p),
            mod(y, modulus: p)
        )
    }

    init(_ x: Number, _ y: Number, over galoisField: Field) {
        self.init(x, y, modulus: galoisField.modulus)
    }
}

public struct ProjectivePointOnCurve<C: Curve>: ProjectivePoint {
    public let x: Number
    public let y: Number
    public let z: Number

    public init(_ x: Number, _ y: Number, _ z: Number) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension ProjectivePointOnCurve {
    init(_ x: Number, _ y: Number, _ z: Number, modulus p: Number) {
        self.init(
            mod(x, modulus: p),
            mod(y, modulus: p),
            mod(z, modulus: p)
        )
    }

    init(_ x: Number, _ y: Number, _ z: Number, over galoisField: Field) {
       self.init(x, y, z, modulus: galoisField.modulus)
    }
}

//class WeierstraßCurve: Curve {}
//class KoblitzCurve: ShortWeierstraßCurve {}

///      𝑆: 𝑦² = 𝑥³ + 𝐴𝑥 + 𝐵
struct ShortWeierstraßCurve: Curve, CustomStringConvertible {
    let galoisField: Field
    let a: Number
    let b: Number

    init(a: Number, b: Number, galoisField: Field) {
        self.a = a
        self.b = b
        self.galoisField = galoisField
    }

    var description: String {
        return "𝑦² = 𝑥³ + 𝐴𝑥 + 𝐵 over \(galoisField)"
    }

    var sageRepresentation: String {
        // Sage Form: y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x + a6
        return "EllipticCurve(GF(\(galoisField.modulus), [\(a), \(b)])"
    }

    func 𝑦²(x: Number) -> Number {
        return galoisField.normalize { x*x*x + a*x + b }
    }

    func equation(_ x: Number, _ y: Number) -> Number {
        return galoisField.normalize { y*y - 𝑦²(x: x) }
    }

    func equation(_ point: Affine) -> Number {
        return equation(point.x, point.y)
    }

    // aka identity
    static let neutralPoint: Affine = .infinity
    static let neutralPointProjective = Projective(0, 1, 0)

    func isPointOnCurve(_ point: Affine) -> Bool {
        // the inifinity point IS indeed on the curve
        guard !point.isInfinity else { return true }
        return equation(point) == 0
    }

    func affineToProjective(_ affinePoint: Affine) -> Projective {
        guard !affinePoint.isInfinity else { return neutralPointProjective }
        let x = affinePoint.x
        let y = affinePoint.y
        return Projective(x, y, 1)
    }

    func projectiveToAffine(_ projectivePoint: Projective) -> Affine {
        guard projectivePoint != neutralPointProjective else { return .infinity }
        let X = projectivePoint.x
        let Y = projectivePoint.y
        let Z = projectivePoint.z
        let x = galoisField.divide(X, by: Z)
        let y = galoisField.divide(Y, by: Z)
        return Affine(x, y)
    }

    /// "add-2007-bl" see: https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-3.html
    /// directly to code: https://www.hyperelliptic.org/EFD/g1p/auto-code/edwards/projective/addition/add-2007-bl-2.op3
    public func addProjectivePoint(_ p1: Projective, to p2: Projective) -> Projective {
        guard !(p1 == neutralPointProjective && p2 == neutralPointProjective) else { return neutralPointProjective }
        guard p1 != neutralPointProjective else { return p2 }
        guard p2 != neutralPointProjective else { return p1 }

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

        return Projective(X3, Y3, Z3, modulus: galoisField.modulus)
    }

    /// "dbl-2007-bl", see: https://hyperelliptic.org/EFD/g1p/auto-shortw-projective-1.html
    /// directly to code: https://hyperelliptic.org/EFD/g1p/auto-code/shortw/projective-1/doubling/dbl-2007-bl.op3
    public func doubleProjectivePoint(_ p: Projective) -> Projective {
        guard p != neutralPointProjective else { return neutralPointProjective }
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

       return Projective(X3, Y3, Z3, modulus: galoisField.modulus)
    }

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

    /// Returns a list of the y-coordinates on the curve at given x.
    func getY(fromX x: Number) -> [Number] {
        let y² = 𝑦²(x: x)
        guard let squares = squareRoots(of: y², modulus: galoisField.modulus) else { return [] }
        var result = [Number]()
        for y in squares {
            // TODO: check inverted point?
            guard isPointOnCurve(Affine(x, y)) else { continue }
            result.append(y)
        }
        return result
    }

    public func invertPoint(_ point: Affine) -> Affine {
        return Affine(point.x, -point.y, over: galoisField)
    }

    public func add(_ p1: Affine, to p2: Affine) -> Affine {
        guard !(p1 == neutralPoint && p2 == neutralPoint) else { return neutralPoint }
        guard p1 != neutralPoint else { print("p1 is neutralPoint, returning p2");return p2 }
        guard p2 != neutralPoint else { print("p1 is neutralPoint, returning p2");return p1 }

        guard p1 != invertPoint(p2) else { return neutralPoint }

        let x1 = p1.x
        let y1 = p1.y
        let x2 = p2.x
        let y2 = p2.y

        let λ = galoisField.divide(y2 - y1, by: x2 - x1)
        let x3 = galoisField.normalize(λ**2 - x1 - x2)
        let y3 = galoisField.normalize(λ * (x1 - x3) - y1)
        return Affine(x3, y3, over: galoisField)
    }

    public func doublePoint(_ p: Affine) -> Affine {
        guard p != neutralPoint else { return neutralPoint }

        let x = p.x
        let y = p.y

        let λ = galoisField.divide(3 * x**2 + a, by: 2 * y)

        let x2 = galoisField.normalize(λ**2 - 2 * x)
        let y2 = galoisField.normalize(λ * (x - x2) - y)

        return Affine(x2, y2, over: galoisField)
    }
}

//typealias Transformation<From: Curve, To: Curve> = (AffinePointOnCurve<From>) -> AffinePointOnCurve<To>
//typealias ToShortWeierstraßPointTransformation<From: ConvertibleToShortWeierstraß> = Transformation<From, ShortWeierstraßCurve>
//typealias ToMontgomeryPointTransformation<From: ConvertibleToMontgomery> = Transformation<From, MontgomeryCurve>
//
//protocol ConvertibleToShortWeierstraß: Curve {
//    func toShortWeierstraß() -> (ShortWeierstraßCurve, ToShortWeierstraßPointTransformation<Self>)
//}
//
//protocol ConvertibleToMontgomery: Curve {
//    func toMontgomery() -> (MontgomeryCurve, ToMontgomeryPointTransformation<Self>)
//}

//final class MontgomeryCurve: Curve {
//
//}
//
//final class EdwardsCurve: Curve, ConvertibleToMontgomery {
//    func toMontgomery() -> (MontgomeryCurve, ToMontgomeryPointTransformation<EdwardsCurve>) {
//        fatalError()
//    }
//}

//class TwistedEdwardsCurve: ShortWeierstraßCurve, ConvertibleToMontgomery {
//    func toMontgomery() -> MontgomeryCurve {
//        fatalError()
//    }
//}


/// Jacobian Coordinates are used to represent elliptic curve points on prime curves y^2 = x^3 + ax + b. They give a speed benefit over Affine Coordinates when the cost for field inversions is significantly higher than field multiplications. In Jacobian Coordinates the triple (X, Y, Z) represents the affine point (X / Z^2, Y / Z^3).
/// Also known as `ProjectiveCoordinates`?: https://www.nayuki.io/res/elliptic-curve-point-addition-in-projective-coordinates/ellipticcurve.py
//public struct JacobianPoint {
//    let x: Number
//    let y: Number
//    let z: Number
//}

