//
//  ModularInverse.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-18.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public func mod(_ number: Number, modulus: Number) -> Number {
    var mod = number % modulus
    if mod < 0 {
        mod = mod + modulus
    }
    guard mod >= 0 else { fatalError("NEGATIVE VALUE") }
    return mod
}

func modularInverse<T: BinaryInteger>(_ x: T, _ y: T, mod: T) -> T {
    let x = x > 0 ? x : x + mod
    let y = y > 0 ? y : y + mod

    let inverse = extendedEuclideanAlgorithm(z: y, a: mod)

    var result = (inverse * x) % mod

    let zero: T = 0
    if result < zero {
        result = result + mod
    }

    return result
}

private func division<T: BinaryInteger>(_ a: T, _ b: T) -> (quotient: T, remainder: T) {
    return (a / b, a % b)
}

/// https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
private func extendedEuclideanAlgorithm<T: BinaryInteger>(z: T, a: T) -> T {
    var i = a
    var j = z
    var y1: T = 1
    var y2: T = 0

    let zero: T = 0
    while j > zero {
        let (quotient, remainder) = division(i, j)

        let y = y2 - y1 * quotient

        i = j
        j = remainder
        y2 = y1
        y1 = y
    }

    return y2 % a
}
