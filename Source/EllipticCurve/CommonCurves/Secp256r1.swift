//
//  Secp256r1.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

/// The curve E: `y² = x³ + ax + b` over Fp
/// `secp256r1` Also known as `prime256v1`, `NIST P-256` or just `P-256`
/// Used by `Neo` and `Cardano`
/// https://www.ietf.org/rfc/rfc5480.txt
public struct Secp256r1: EllipticCurve {

    /// `2^256 - 2^224 + 2^192 + 2^96 - 1` <=> `2^224 * (2^32 − 1) + 2^192 +2^96 − 1`
    public static let P = Number(hexString: "0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF")!

    public static let a = Number(hexString: "0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC")!
    public static let b = Number(hexString: "0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B")!
    public static let G = Point(
        x: Number(hexString: "0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296")!,
        y: Number(hexString: "0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5")!
    )

    public static let N = Number(hexString: "0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551")!
    public static let h = Number(1)
    public static let name = CurveName.secp256r1
}
