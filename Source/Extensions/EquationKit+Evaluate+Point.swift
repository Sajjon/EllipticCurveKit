//
//  EquationKit+Evaluate+Point.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import EquationKit

public extension PolynomialStruct where TermType == TermStruct<ExponentiationStruct<Number>> {
    func isZero(point: Point, modulus p: Number) -> Bool {
        guard let twoDimensionalPoint = point as? TwoDimensionalPoint else { return false }
        return isZero(point: twoDimensionalPoint, modulus: p)
    }

    func isZero(point: TwoDimensionalPoint, modulus p: Number) -> Bool {
        return isZero(x: point.x, y: point.y, modulus: p)
    }

    func isZero(x: Number, y: Number, modulus p: Number) -> Bool {
        return evaluate(modulus: p) {[ 𝑥 <- x, 𝑦 <- x ]} == 0
    }
}
