//
//  EllipticCurve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol EllipticCurve { //where Point.Curve == Self {
    //    associatedtype Point: EllipticCurvePoint
    typealias Point = AffinePoint<Self>
    static var P: Number { get }
    static var a: Number { get }
    static var b: Number { get }
    static var G: Point { get }
    static var N: Number { get }
    static var h: Number { get }
}

private extension EllipticCurve {
    var P: Number { return Self.P }
    var a: Number { return Self.a }
    var b: Number { return Self.b }
    var G: Point { return Self.G }
    var N: Number { return Self.N }
    var h: Number { return Self.h }
}

extension EllipticCurve {
    static func modP(_ expression: () -> Number) -> Number {
        return mod(expression(), modulus: P)
    }

    static func modN(_ expression: () -> Number) -> Number {
        return mod(expression(), modulus: N)
    }
}

public extension EllipticCurve {

    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "jacobi(point.y) can be implemented as jacobi(point.y * point.z mod P)."
    //
    /// Can be computed more efficiently using an extended GCD algorithm.
    /// reference: https://en.wikipedia.org/wiki/Jacobi_symbol#Calculating_the_Jacobi_symbol
    static func jacobi(_ point: Point) -> Number {
        func jacobi(_ number: Number) -> Number {
            let division = (P - 1).quotientAndRemainder(dividingBy: 2)
            /// pow(number, floor((P - 1) / 2), P)
            return pow(number, division.quotient, P)
        }
        return jacobi(point.y) // can be changed to jacobi(point.y * point.z % Curve.P)
    }


    static func sign(message: Message, keyPair: KeyPair<Self>) -> Signature<Self> {
        return sign(message: message, privateKey: keyPair.privateKey, publicKey: keyPair.publicKey)
    }
    
    static func sign(message: Message, privateKey: PrivateKey<Self>, publicKey: PublicKey<Self>) -> Signature<Self> {
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

        /// "Choose a random `k` from the allowed set" https://en.wikipedia.org/wiki/Schnorr_signature
        /// Here we make sure that k is not too large.
        if jacobi(R) != 1 {
            k = N - k
        }

        let e = Crypto.sha2Sha256(R.x.asData() + publicKey.data.compressed + message.asData()).toNumber()

        /// GOTCHA: `secp256k1` uses `mod P` for all operations, but for the creation of the Schnorr signature, we use `mod n`, ref: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074#gotchas
        let signatureSuffix = modN { k + e * privateKey.number }
        return Signature<Self>(r: R.x, s: signatureSuffix)!
    }

    static func addition(_ p1: Point?, _ p2: Point?) -> Point? {
        return Point.addition(p1, p2)
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Self>, publicKey: PublicKey<Self>) -> Bool {
        guard publicKey.point.isOnCurve() else { return false }
        let r = signature.r
        let s = signature.s
        let e = Crypto.sha2Sha256(r.asData() + publicKey.data.compressed + message.asData()).toNumber()

        guard
            let R = addition(G * s, publicKey.point * (N - e)),
            jacobi(R) == 1,
            R.x == r /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % P.`
            else { return false }

        return true
    }
}
