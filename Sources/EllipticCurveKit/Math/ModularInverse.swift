//
//  ModularInverse.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-18.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public extension Number {
    func modulus(_ p: Number) -> Number {
        return EllipticCurveKit.mod(self, modulus: p)
    }
    
    func modulus(_ expression: () -> Number) -> Number {
        return modulus(expression())
    }
    
    static func % (lhs: Number, rhs: Number) -> Number {
        return lhs.modulus(rhs)
    }
}

func mod<T>(_ number: T, modulus: T) -> T where T: BinaryInteger {
    var mod = number % modulus
    if mod < 0 {
        mod = mod + modulus
    }
    guard mod >= 0 else { fatalError("NEGATIVE VALUE") }
    return mod
}

func mod<T>(_ modulus: T, expression: () -> T) -> T where T: BinaryInteger {
    return mod(expression(), modulus: modulus)
}

func divide<T: BinaryInteger>(_ x: T, by y: T, mod p: T) -> T {
    let x = x > 0 ? x : x + p
    let y = y > 0 ? y : y + p
    let euclideanResult = extendedGreatestCommonDivisor(y, p)
    let inverse = euclideanResult.bézoutCoefficients.0
    return mod(inverse * x, modulus: p)
}

struct ExtendedEuclideanAlgorithmResult<T: BinaryInteger> {
    
    /// Greatest Common Divisor
    let gcd: T
    let bézoutCoefficients: (T, T)
    let quotientsByTheGCD: (T, T)
}

/// https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
func extendedGreatestCommonDivisor<T: BinaryInteger>(_ a: T, _ b: T) -> ExtendedEuclideanAlgorithmResult<T> {
    
    var s: T = 0
    var oldS: T = 1
    
    var t: T = 1
    var oldT: T = 0
    
    var r: T = b
    var oldR: T = a
    
    while r != 0 {
        let q = oldR.quotientAndRemainder(dividingBy: r).quotient
        (oldR, r) = (r, oldR - q * r)
        (oldS, s) = (s, oldS - q * s)
        (oldT, t) = (t, oldT - q * t)
        
    }
    let bézoutCoefficients = (oldS, oldT)
    let gcd = oldR
    let quotientsByTheGCD = (t, s)
    return ExtendedEuclideanAlgorithmResult(
        gcd: gcd,
        bézoutCoefficients: bézoutCoefficients,
        quotientsByTheGCD: quotientsByTheGCD
    )
}

private func division<T: BinaryInteger>(_ a: T, _ b: T) -> (quotient: T, remainder: T) {
    return (a / b, a % b)
}
