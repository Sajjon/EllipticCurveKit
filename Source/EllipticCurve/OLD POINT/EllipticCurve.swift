//
//  EllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public enum CurveName {
    case secp256k1, secp256r1
}

public protocol EllipticCurve {
    static var form: EllipticCurveForm { get }
    typealias Point = AffinePoint<Self>
    static var modulus: Number { get }
    static var a: Number { get }
    static var b: Number { get }
    static var generator: Point { get }
    static var order: Number { get }
    static var cofactor: Number { get }
    static var name: CurveName { get }
}

public extension EllipticCurve {
    static var P: Number { return modulus }
    static var N: Number { return order }
    static var G: Point { return generator }
    static var h: Number { return cofactor }
}

public extension EllipticCurve {
    static var form: EllipticCurveForm { return .shortWeierstrass }
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

    static func modInverseP(_ v: Number, _ w: Number) -> Number {
        return divide(v, by: w, mod: P)
    }

    static func modInverseN(_ v: Number, _ w: Number) -> Number {
        return divide(v, by: w, mod: N)
    }
}
