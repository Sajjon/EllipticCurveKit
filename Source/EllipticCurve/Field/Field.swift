//
//  Field.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-08-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

public class Field: CustomStringConvertible {

    let modulus: Number

    init(modulus: Number) {
        self.modulus = modulus
    }
}

public extension Field {

    func mod(_ number: Number) -> Number {
         return number % modulus
    }

    func mod(expression: @escaping () -> Number) -> Number {
        return mod(expression())
    }

    func modInverse(_ v: Number, _ w: Number) -> Number {
        return divide(v, by: w, mod: modulus)
    }

    func squareRoots(of x: Number) -> [Number] {
        guard let roots = SwiftCrypto.squareRoots(of: x, modulus: modulus) else { return [] }
        return roots
    }
}

public extension Field {
    public var description: String {
        return "finite field modulus \(modulus)"
    }
}
