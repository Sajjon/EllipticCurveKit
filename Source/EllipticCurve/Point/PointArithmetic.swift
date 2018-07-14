//
//  PointArithmetic.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
    return base.power(exponent, modulus: modulus)
}

public func mod(_ number: Number, modulus: Number) -> Number {
    var mod = number % modulus
    if mod < 0 {
        mod = mod + modulus
    }
    guard mod >= 0 else { fatalError("NEGATIVE VALUE") }
    return mod
}
