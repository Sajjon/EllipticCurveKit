//
//  Schnorr.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-16.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Schnorr<CurveType: EllipticCurve>: Signing {
    public typealias Curve = CurveType
}

public extension Schnorr {

    static func sign(_ message: Message, using keyPair: KeyPair<Curve>) -> Signature<Curve> {
        return sign(message, privateKey: keyPair.privateKey, publicKey: keyPair.publicKey)
    }

    static func sign(_ message: Message, privateKey: PrivateKey<Curve>, publicKey: PublicKey<Curve>) -> Signature<Curve> {
        /// assign `K` according RFC-6979:
        ///
        /// https://tools.ietf.org/html/rfc6979

        var k = Number(data: Crypto.sha2Sha256(privateKey.asData() + message.asData()))
        let R = Curve.G * k // `nonce point`? ( https://github.com/yuntai/schnorr-examples/blob/master/schnorr/schnorr.py )

        /// "Choose a random `k` from the allowed set" https://en.wikipedia.org/wiki/Schnorr_signature
        /// Here we make sure that k is not too large.
        if jacobi(R) != 1 {
            k = Curve.N - k
        }

        let e = Crypto.sha2Sha256(R.x.as256bitLongData() + publicKey.data.compressed + message.asData()).toNumber()

        /// GOTCHA: `secp256k1` uses `mod P` for all operations, but for the creation of the Schnorr signature, we use `mod n`, ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#gotchas
        let signatureSuffix = Curve.modN { k + e * privateKey.number }
        return Signature<Curve>(r: R.x, s: signatureSuffix)!
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {
        guard publicKey.point.isOnCurve() else { return false }
        let r = signature.r
        let s = signature.s
        let e = Crypto.sha2Sha256(r.as256bitLongData() + publicKey.data.compressed + message.asData()).toNumber()

        guard
            let R = Curve.addition((Curve.G * s), (publicKey.point * (Curve.N - e))),
            jacobi(R) == 1,
            R.x == r /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % P.`
            else { return false }

        return true
    }
}

private extension Schnorr {
    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "jacobi(point.y) can be implemented as jacobi(point.y * point.z mod P)."
    //
    /// Can be computed more efficiently using an extended GCD algorithm.
    /// reference: https://en.wikipedia.org/wiki/Jacobi_symbol#Calculating_the_Jacobi_symbol
    static func jacobi(_ point: Curve.Point) -> Number {
        func jacobi(_ number: Number) -> Number {
            let division = (Curve.P - 1).quotientAndRemainder(dividingBy: 2)
            return number.power(division.quotient, modulus: Curve.P)
        }
        return jacobi(point.y) // can be changed to jacobi(point.y * point.z % Curve.P)
    }
}

