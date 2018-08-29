//
//  ThreeDimensionalPoint.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol ThreeDimensionalPoint: TwoDimensionalPoint {
    var z: Number { get }
}

public extension ThreeDimensionalPoint {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.z == rhs.z
    }
}

//public extension ThreeDimensionalPoint {
//
//    init(x: Number, y: Number) { fatalError("use `init(x:y:z)` initializer") }
//
//    var z: Number {
//        return vector[2]
//    }
//}
