//
//  ProjectivePointOnCurve.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct ProjectivePointOnCurve<C: CurveForm>: ThreeDimensionalPointOnCurve {
    public typealias CurveType = C
    public let x: Number
    public let y: Number
    public let z: Number

    public init(x: Number, y: Number, z: Number) {
        self.x = x
        self.y = y
        self.z = z
    }
}
