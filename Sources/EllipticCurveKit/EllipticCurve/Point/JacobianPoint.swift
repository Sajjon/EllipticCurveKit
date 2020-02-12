//
//  JacobianPoint.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// Jacobian Coordinates are used to represent elliptic curve points on prime curves y^2 = x^3 + ax + b. They give a speed benefit over Affine Coordinates when the cost for field inversions is significantly higher than field multiplications. In Jacobian Coordinates the triple (X, Y, Z) represents the affine point (X / Z^2, Y / Z^3).
/// Also known as `ProjectiveCoordinates`?: https://www.nayuki.io/res/elliptic-curve-point-addition-in-projective-coordinates/ellipticcurve.py
public struct JacobianPoint {
    let x: Number
    let y: Number
    let z: Number
}
