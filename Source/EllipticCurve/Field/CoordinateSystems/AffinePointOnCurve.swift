//
//  AffinePointOnCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-08-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct AffinePointOnCurve<C: Curve>: TwoDimensionalPoint, Equatable {
    public let x: Number
    public let y: Number
    public let isInfinity: Bool
    public init(x: Number, y: Number, isInfinity: Bool = false) {
        self.x = x
        self.y = y
        self.isInfinity = isInfinity
    }

    static var infinity: AffinePointOnCurve<C> {
        return AffinePointOnCurve(x: 0, y: 0, isInfinity: true)
    }

    public static func == (lhs: AffinePointOnCurve<C>, rhs: AffinePointOnCurve<C>) -> Bool {
        if lhs.isInfinity && rhs.isInfinity { return true }
        if lhs.isInfinity { return false }
        if rhs.isInfinity { return false }
        return lhs.x == rhs.x && rhs.y == lhs.y
    }
}

public extension AffinePointOnCurve {
    init(point: TwoDimensionalPoint) {
        self.init(x: point.x, y: point.y)
    }
}

extension AffinePointOnCurve {
    init(x: Number, y: Number, modulus p: Number) {
        self.init(
            x: x % p,
            y: y % p
        )
    }

    init(x: Number, y: Number, over galoisField: Field) {
        self.init(x: x, y: y, modulus: galoisField.modulus)
    }
}
