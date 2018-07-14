//
//  Secp256k1.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Secp256k1: EllipticCurve {
//    public typealias Point = AffinePoint<Secp256k1>
    public static let P = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!
    public static let N = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
    public static let a = Number(0)
    public static let b = Number(7)
    public static let G = Point(
        x: Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!,
        y: Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
    )
}

