//
//  Curve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

struct Point: Equatable {
    let x: Number
    let y: Number
    init(x: Number!, y: Number!) {
        self.x = x
        self.y = y
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        var p1 = lhs
        var p2 = rhs

        func calculateLam() -> Number {
            var lam: Number

            if p1 == p2 {
                lam = 3 * p1.x * p1.x * pow(2 * p1.y, p - 2, p)
            } else {
                lam = (p2.y - p1.y) * pow(p2.x - p1.x, p - 2, p)
            }
            return lam % p
        }

        let lam = calculateLam()

        let x3 = (lam * lam - p1.x - p2.x) % p
        let y = (lam * (p1.x - x3) - p1.y) % p

        return Point(x: x3, y: y)
    }

    static func * (point: Point, number: Number) -> Point {
        return point_mul(point, number)
    }
}

let p = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!
let n = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
let x = Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!
let y = Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
let G = Point(x: x, y: y)

func point_add(_ p1: Point?, _ p2: Point?) -> Point? {
    guard let p1 = p1 else { return p2 }
    guard let p2 = p2 else { return p1 }

    if p1.x == p2.x && p1.y != p2.y {
        return nil
    }

    return p1 + p2
}

func point_mul(_ p: Point, _ n: Number) -> Point {
    var n = n
    var p: Point? = p
    var r: Point!
    for i in 0..<256 { // n.bitWidth
        if n.magnitude[bitAt: i] {
            r = point_add(r, p)
        }
        p = point_add(p, p)
    }
    return r
}


func on_curve(point: Point) -> Bool {
    //  secp256k1: y^2 = x^3 + ax + b <=> given: `a: 0` <=> y^2 = x^3 + 7
    return (pow(point.y, 2, p) - pow(point.x, 3, p)) % p == 7
}

/// pow(x, floor((p - 1) / 2), p)
func jacobi(_ x: Number) -> Number {
    let pMinus1: Number = p - 1
    let division = pMinus1.quotientAndRemainder(dividingBy: 2)
    return pow(x, division.quotient, p)
}

func schnorr_sign(message: Message, privateKey: PrivateKey, publicKey: PublicKeyPoint) -> Signature {

    let messageData = message.data

    let privateKeyData = privateKey.number.asData()
    var k = Number(data: Crypto.sha2Sha256(privateKeyData + messageData))

    let R = G * k

    if jacobi(R.y) != 1 {
        k = n - k
    }

    let eData = Crypto.sha2Sha256(R.x.asData() + publicKey.data.compressed + messageData)
    let e = Number(data: eData)

    let signatureSuffix = (k + e + privateKey.number) % n
    let signatureValue: Number = R.x + signatureSuffix
    guard let signature = Signature(number: signatureValue) else { fatalError("failed to sign") }
    return signature
}


func schnorr_verify(message: Message, publicKey: PublicKeyPoint, signature: Signature) -> Bool {
    let signatureData = signature.data
    guard
        on_curve(point: publicKey.point),
        case let rData = signatureData.prefix(32),
        case let sData = signatureData.suffix(32),
        rData.count == 32,
        sData.count == 32,
        case let r = Number(data: rData),
        case let s = Number(data: sData),
        r < p,
        s < p
    else { return false }

    let e = Number(data: Crypto.sha2Sha256(rData + publicKey.data.compressed + message.data))

    guard let R = point_add((G * s), (publicKey.point * (n - e))) else { return false }
    guard jacobi(R.y) == 1 else { return false }
    guard R.x == r else { return false }

    return true
}
