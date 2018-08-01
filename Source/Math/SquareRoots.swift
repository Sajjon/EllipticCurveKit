//
//  SquareRoots.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-29.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

func legendreSymbol(_ n: Number, modulus p: Number) -> Number {
    let legendreSymbol = n.power((p - 1)/2, modulus: p)
    if legendreSymbol == p - 1 {
        return -1
    }
    guard (legendreSymbol == 0 || legendreSymbol == 1) else { fatalError() }
    return legendreSymbol
}

/// https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm#The_algorithm
func tonelliShanks(_ n: Number, modulus p: Number) -> [Number]? {
    var q, s, z, c, b, r, t, m, i: Number

    // Step 1: By factoring out powers of 2, find Q and S such that p^d - 1 = Q 2^S with Q odd
    s = 0
    q = p - 1
    while mod(q, modulus: 2) == 0 {
        s += 1
        q /= 2
    }

    if s == 1 {
        r = n.power((p + 1) / 4, modulus: p)
        if mod(r*r, modulus: p) == n {
            return [r, p - r]
        }
    }

    // Find the first quadratic non-residue z by brute-force search
    // Step 2
    z = 1
    while legendreSymbol(z, modulus: p) != -1 {
        z += 1
    }
    c = z.power(q, modulus: p)

    // Step 3
    r = n.power((q + 1) / 2, modulus: p)
    t = n.power(q, modulus: p)
    m = s
    while t != 1 {
        // Find the lowest i such that t^(2^i) = 1
        i = 0
        var tt: Number = t
        while tt != 1 {
            tt = mod(tt * tt, modulus: p)
            i += 1
            if i == m { return nil }
        }

        // Update next value to iterate

        /// Calculates 2^(m - i - 1)
        let exponentForB = Number(2).power((m - i - 1), modulus: p - 1)
        b = c.power(exponentForB, modulus: p)
        c = mod(p) { b * b }
        r = mod(p) { r * b }
        t = mod(p) { t * c }
        m = i
    }

    if mod(r * r, modulus: p) == n { return [r, p - r] }
    return nil
}

/// Calculate the square roots 𝑥² ≡ n (mod p).
public func squareRoots(of n: Number, modulus p: Number) -> [Number]? {
    let n = mod(n, modulus: p)

    guard n != 0 else { return [0] }
    guard p != 2 else { return [n] }

    guard legendreSymbol(n, modulus: p) == 1 else { return nil }

    // Common case #1
    if mod(p, modulus: 4) == 3 {
        let x = n.power((p + 1)/4, modulus: p)
        return [x, p-x]
    }

    // Common case #2
    if mod(p, modulus: 8) == 5 {
        if n == n.power((p + 3)/4, modulus: p) {
            let x = n.power((p + 3)/8, modulus: p)
            return [x, p-x]
        }
        let s = n.power((p + 3)/8, modulus: p)

        guard let ts = tonelliShanks(p - 1, modulus: p) else { return nil }

        let x = mod(ts[0] * s, modulus: p)
        return [x, p-x]
    }

    // Shouldn't end up here very often.
    return tonelliShanks(n, modulus: p)

}

