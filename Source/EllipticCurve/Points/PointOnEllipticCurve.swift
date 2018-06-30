//
//  PointOnEllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PointOnEllipticCurve {

    private let curve: EllipticCurve
    private let point: Point

    public init(curve: EllipticCurve, point: Point) {
        self.curve = curve
        self.point = point
    }
}
