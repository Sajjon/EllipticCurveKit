//
//  ThreeDimensionalPointOnCurve.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol ThreeDimensionalPointOnCurve: ThreeDimensionalPoint, Equatable {
    associatedtype CurveType: CurveForm
    init(x: Number, y: Number, z: Number)
}

extension ThreeDimensionalPointOnCurve {
    init(x: Number, y: Number, z: Number, modulus p: Number) {
        self.init(
            x: x % p,
            y: y % p,
            z: z % p
        )
    }

    init(x: Number, y: Number, z: Number, over galoisField: Field) {
        self.init(x: x, y: y, z: z, modulus: galoisField.modulus)
    }
}
