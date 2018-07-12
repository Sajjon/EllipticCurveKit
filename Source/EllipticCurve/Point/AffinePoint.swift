//
//  Point.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct AffinePoint: Equatable, CustomStringConvertible {
    let x: Number
    let y: Number
    public init(x: Number, y: Number) {
        precondition(x >= 0, "Coordinates should have non negative values, x was negative: `\(x)`")
        precondition(y >= 0, "Coordinates should have non negative values, y was negative: `\(y)`")
        self.x = x
        self.y = y
    }

    static func * (point: AffinePoint, number: Number) -> AffinePoint {
        return point_mul(point, number)
    }
}

public extension AffinePoint {
    var description: String {
        return "(x: \(x.asHexString()), y: \(x.asHexString())"
    }
}

