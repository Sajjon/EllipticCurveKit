//
//  Signing.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Signing {
    associatedtype CurveType: EllipticCurve
}
public struct Schnorr<Curve: EllipticCurve>: Signing {
    public typealias CurveType = Curve
}
