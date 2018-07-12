//
//  Signing.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Signing {
    associatedtype Curve: EllipticCurve
}
public struct Schnorr<CurveType: EllipticCurve>: Signing {
    public typealias Curve = CurveType
}

/// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
/// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
///
/// WHEN Jacobian Coordinates: "on_curve(point) can be implemented as `y^2 = x^3 + 7z^6 mod p`"
func on_curve(point: Point) -> Bool {
    //  secp256k1: y^2 = x^3 + ax + b <=> given: `a: 0` <=> y^2 = x^3 + 7
    return (pow(point.y, 2, p) - pow(point.x, 3, p))~ == 7
}

/// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
/// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
///
/// WHEN Jacobian Coordinates: "jacobi(point.y) can be implemented as jacobi(point.y * point.z mod p)."
//
/// Can be computed more efficiently using an extended GCD algorithm.
/// reference: https://en.wikipedia.org/wiki/Jacobi_symbol#Calculating_the_Jacobi_symbol
func jacobi(_ point: Point) -> Number {
    func jacobi(_ number: Number) -> Number {
        let division = (p - 1).quotientAndRemainder(dividingBy: 2)
        /// pow(number, floor((p - 1) / 2), p)
        return pow(number, division.quotient, p)
    }
    return jacobi(point.y) // can be changed to jacobi(point.y * point.z % Curve.P)
}

func schnorr_sign(message: Message, privateKey: PrivateKey, publicKey: PublicKey) -> Signature {


    let privateKeyData = privateKey.number.asData()
    let msgDataFromHex: Data = Data(hex: message.hexString)

    // `k` = nonce ?
    // SOURCE: https://github.com/yuntai/schnorr-examples/blob/master/schnorr/schnorr.py
    //

    // `k = an ephemeral random value (supposed to change for every signature)
    // ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#test-vector-1

    // this fact is NOT VERIFIED, the inital implementation of this code uses:
    // https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#appendix-a-reference-code
    // where `k = sha256(seckey + msg)`
    //
    // But hey, 2 vs 1. So `k` should probably be `nonce`/random?
    var k = Number(data: Crypto.sha2Sha256(privateKeyData + msgDataFromHex))

    let R = G * k // `nonce point`? ( https://github.com/yuntai/schnorr-examples/blob/master/schnorr/schnorr.py )

    if jacobi(R) != 1 {
        k = n - k
    }

    let e = Number(data:
        Crypto.sha2Sha256(R.x.asData() + publicKey.data.compressed + msgDataFromHex)
    )

    // GOTCHA: `secp256k1` uses `mod p` for all operations, but for the creation of the Schnorr signature, we use `mod n`
    // ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#gotchas
    let signatureSuffix = (k + e + privateKey.number)~&~
    let signatureHex = R.x.asHexString() + signatureSuffix.asHexString()
    print("Signature value is: \n\(signatureHex)")
    let signature = Signature(hex: signatureHex)
    return signature
}


func schnorr_verify(message: Message, publicKey: PublicKey, signature: Signature) -> Bool {
    var signatureHex = signature.hexString
    print("🔎 VERIFYING: signature: `\(signature)`, message: `\(message)`")
    guard on_curve(point: publicKey.point) else { print("⚠️🔎 NOT ON CURVE (point: `\(publicKey.point)`"); return false }
    let rHex = String(signatureHex.prefix(64))
    let sHex = String(signatureHex.suffix(64))
    //        rData.count == 32,
    //        sData.count == 32,
    guard let r = Number(hexString: rHex) else { print("⚠️🔎 failed to create `r` as number from hexstring: `\(rHex)`"); return false }
    guard let s = Number(hexString: sHex) else { print("⚠️🔎 failed to create `s` as number from hexstring: `\(sHex)`"); return false }
    guard r < p else { print("⚠️🔎 r >= p (r: `\(r)`, p: `\(p)`"); return false }
    guard s < n else { print("⚠️🔎 s >= n (s: `\(s)`, n: `\(n)`"); return false }

    print("r.hex: `\(rHex)`")
    print("s.hex: `\(sHex)`")

    print("publicKey.hex.compressed: `\(publicKey.hex.compressed)`")
    print("message: `\(message.hexString)`")

    //    let rDataFromNumber: Data = r.asData()
    let rDataFromHex: Data = Data(hex: rHex)
    //    assert(rDataFromNumber == rDataFromHex, "Should equal, \(rDataFromNumber.toHexString()) != \(rDataFromHex.toHexString())")


    //    let msgDataFromNumber: Data = Number(hexString: message.hexString)!.asData()

    let msgDataFromHex: Data = Data(hex: message.hexString)
    //    assert(msgDataFromNumber == msgDataFromHex, "Should equal")

    let pkDataRaw: Data = publicKey.data.compressed
    let pkDataFromHex: Data = Data(hex: publicKey.hex.compressed)
    assert(pkDataRaw == pkDataFromHex, "Should equal, \(pkDataRaw.toHexString()) != \(pkDataFromHex.toHexString())")

    let e: Number = {
        let eData = Crypto.sha2Sha256(rDataFromHex + pkDataFromHex + msgDataFromHex)
        return Number(data: eData)
    }()

    print("e.hex: `\(e.asHexString())`")

    //    let e = Number(data: Crypto.sha2Sha256(rData + publicKey.data.compressed + message.data))

    guard let R = point_add((G * s), (publicKey.point * (n - e))) else { print("⚠️🔎 `R` from addition is `nil`"); return false }

    print("R.x: `\(R.x)`")
    print("R.y: `\(R.y)`")

    guard jacobi(R) == 1 else { print("⚠️🔎 jacobi(R) != 1, (was: `\(jacobi(R))`)"); return false }

    /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % p.`
    guard R.x == r else { print("⚠️🔎 R.x != r, (R.x: `\(R.x)`, r: `\(r)`)"); return false }

    return true
}
