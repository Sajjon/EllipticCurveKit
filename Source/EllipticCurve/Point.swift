//
//  Point.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Point: Equatable, CustomStringConvertible {
    let x: Number
    let y: Number
    public init(x: Number, y: Number) {
//        var x = x
//        var y = y
//        // Handle negative values in Swift.
//        // https://stackoverflow.com/a/3883019/1311272
//        if x < 0 {
//            x = x + p
//        }
//        if y < 0 {
//            y = y + p
//        }
        guard x >= 0, y >= 0 else { fatalError("NEGATIVE VALUES") }
        self.x = x
        self.y = y
    }

    static func * (point: Point, number: Number) -> Point {
        return point_mul(point, number)
    }
}

public extension Point {
    var description: String {
        return "(x: \(x.asHexString()), y: \(x.asHexString())"
    }
}

/// Jacobian Coordinates are used to represent elliptic curve points on prime curves y^2 = x^3 + ax + b. They give a speed benefit over Affine Coordinates when the cost for field inversions is significantly higher than field multiplications. In Jacobian Coordinates the triple (X, Y, Z) represents the affine point (X / Z^2, Y / Z^3).
/// Also known as `ProjectiveCoordinates`?: https://www.nayuki.io/res/elliptic-curve-point-addition-in-projective-coordinates/ellipticcurve.py
public struct JacobianPoint {
    let x: Number
    let y: Number
    let z: Number
}

var point_add: Addition = addition_v1
var point_mul: Multiplication = multiplication_v1

postfix operator ~
public extension Number {
    static postfix func ~ (number: Number) -> Number {
        return modP(number)
    }
}
postfix operator ~&~
public extension Number {
    static postfix func ~&~ (number: Number) -> Number {
        return modN(number)
    }
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
