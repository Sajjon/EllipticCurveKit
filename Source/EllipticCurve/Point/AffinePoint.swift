//
//  Point.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct AffinePoint<CurveType: EllipticCurve>: EllipticCurvePoint {
    public typealias Curve = CurveType
    public let x: Number
    public let y: Number

    public lazy var ax: Number = {
        return Curve.a * x
    }()

    public lazy var y²: Number = {
        return pow(y, 2, Curve.P)
    }()

    public lazy var x²: Number = {
        return pow(x, 2, Curve.P)
    }()

    public lazy var x³: Number = {
        return pow(x, 3, Curve.P)
    }()

    public init(x: Number, y: Number) {
        precondition(x >= 0, "Coordinates should have non negative values, x was negative: `\(x)`")
        precondition(y >= 0, "Coordinates should have non negative values, y was negative: `\(y)`")
        self.x = x
        self.y = y
    }
}
