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
    // `k` denotes `Nonce` ?
    // SOURCE: https://github.com/yuntai/schnorr-examples/blob/master/schnorr/schnorr.py
    //

    // `k = an ephemeral random value (supposed to change for every signature)
    // ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#test-vector-1

    // this fact is NOT VERIFIED, the inital implementation of this code uses:
    // https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#appendix-a-reference-code
    // where `k = sha256(seckey + msg)`
    //
    // But hey, 2 vs 1. So `k` should probably be `nonce`/random?
    var k = Number(data: Crypto.sha2Sha256(privateKey.asData() + message.asData()))

    let R = G * k // `nonce point`? ( https://github.com/yuntai/schnorr-examples/blob/master/schnorr/schnorr.py )

    if jacobi(R) != 1 {
        k = n - k
    }

    let e = Crypto.sha2Sha256(Data(hex: R.x.asHexStringLength64()) + publicKey.data.compressed + message.asData()).toNumber()

    /// GOTCHA: `secp256k1` uses `mod p` for all operations, but for the creation of the Schnorr signature, we use `mod n`, ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#gotchas
    let signatureSuffix = modN(k + e * privateKey.number)
    let signatureHex = R.x.asHexStringLength64() + signatureSuffix.asHexStringLength64()
    return Signature(hex: signatureHex)
}

func schnorr_verify(message: Message, publicKey: PublicKey, signature: Signature) -> Bool {
    guard
        on_curve(point: publicKey.point),
        case let rHex = String(signature.hexString.prefix(64)),
        case let sHex = String(signature.hexString.suffix(64)),
        let r = Number(hexString: rHex),
        let s = Number(hexString: sHex),
        r < p,
        s < n
        else { return false }

    let e: Number = {
        let inputData: Data = Data(hex: rHex) + publicKey.data.compressed + message.asData()
        let eData = Crypto.sha2Sha256(inputData)
        return Number(data: eData)
    }()

    guard
        let R = point_add((G * s), (publicKey.point * (n - e))),
        jacobi(R) == 1,
        R.x == r /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % p.`
        else { return false }

    return true
}
