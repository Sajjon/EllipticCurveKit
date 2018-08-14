//
//  EllipticCurvePoint.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

// Potential speed up of Point Artihmetic checkout: https://github.com/conz27/crypto-test-vectors/blob/master/ecc.py

public protocol EllipticCurvePoint: Equatable, CustomStringConvertible {
    associatedtype Curve: EllipticCurve
    var x: Number { get }
    var y: Number { get }

    init(x: Number, y: Number)

    static func addition(_ p1: Self?, _ p2: Self?) -> Self?

    static func * (point: Self, number: Number) -> Self
}
