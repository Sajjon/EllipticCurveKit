//
//  Schnorr.swift
//  SwiftCrypto
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
        if Curve.jacobi(R) != 1 {
            k = Curve.N - k
        }

        let e = Crypto.sha2Sha256(R.x.asData() + publicKey.data.compressed + message.asData()).toNumber()

        /// GOTCHA: `secp256k1` uses `mod P` for all operations, but for the creation of the Schnorr signature, we use `mod n`, ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#gotchas
        let signatureSuffix = Curve.modN { k + e * privateKey.number }
        return Signature<Curve>(r: R.x, s: signatureSuffix)!
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {
        guard publicKey.point.isOnCurve() else { return false }
        let r = signature.r
        let s = signature.s
        let e = Crypto.sha2Sha256(r.asData() + publicKey.data.compressed + message.asData()).toNumber()

        guard
            let R = Curve.addition((Curve.G * s), (publicKey.point * (Curve.N - e))),
            Curve.jacobi(R) == 1,
            R.x == r /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % P.`
            else { return false }

        return true
    }
}

