//
//  PointArithmetic.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias Point = AffinePoint

var point_add: Addition = addition_v1
var point_mul: Multiplication = multiplication_v1

postfix operator ~
extension Number {
    static postfix func ~ (number: Number) -> Number {
        return modP(number)
    }
}

postfix operator ~&~
extension Number {
    static postfix func ~&~ (number: Number) -> Number {
        return modN(number)
    }
}

func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
    return base.power(exponent, modulus: modulus)
}

func mod(_ number: Number, modulus: Number) -> Number {
    var mod = number % modulus
    if mod < 0 {
        mod = mod + modulus
    }
    guard mod >= 0 else { fatalError("NEGATIVE VALUE") }
    return mod
}

func modP(_ number: Number) -> Number {
    return mod(number, modulus: p)
}

func modN(_ number: Number) -> Number {
    return mod(number, modulus: n)
}

/// https://en.wikipedia.org/wiki/Elliptic_curve#The_group_law
typealias Addition = (Point?, Point?) -> Point?
/// https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
typealias Multiplication = (Point, Number) -> Point

/// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
/// "Addition of points refers to the usual elliptic curve group operation."
/// reference: https://en.wikipedia.org/wiki/Elliptic_curve#The_group_law
func addition_v1(_ p1: Point?, _ p2: Point?) -> Point? {
    guard let p1 = p1 else { return p2 }
    guard let p2 = p2 else { return p1 }

    if p1.x == p2.x && p1.y != p2.y {
        return nil
    }

    func calculateLam() -> Number {
        var lam: Number

        if p1 == p2 {
            lam = 3 * p1.x * p1.x * pow(2 * p1.y, p - 2, p)
        } else {
            lam = (p2.y - p1.y) * pow(p2.x - p1.x, p - 2, p)
        }
        return lam~
    }

    let lam = calculateLam()

    let x3 = (lam * lam - p1.x - p2.x)~
    let y = (lam * (p1.x - x3) - p1.y)~

    return Point(x: x3, y: y)
}

/// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
/// "Multiplication of an integer and a point refers to the repeated application of the group operation."
/// reference: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
func multiplication_v1(_ p: Point, _ n: Number) -> Point {
    var n = n
    var p: Point? = p
    var r: Point!
    for i in 0..<256 { // n.bitWidth
        if n.magnitude[bitAt: i] {
            r = point_add(r, p)
        }
        p = point_add(p, p)
    }
    return r
}
