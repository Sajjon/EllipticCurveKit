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

    static func sign(_ message: Message, using keyPair: KeyPair<CurveType>, personalizationDRBG: Data) -> Signature<Curve> {

        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey

        let drbg = HMAC_DRBG(message: message, privateKey: privateKey, personalization: personalizationDRBG)

        let length = Curve.N.asTrimmedData().bytes.count

        var signature: Signature<Curve>?
        while signature == nil {
            let k = drbg.generateNumberOf(length: length).result
            let K = Number(data: k)
            signature = trySign(message, privateKey: privateKey, k: K, publicKey: publicKey)
        }

        return signature!
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

    /// Hash (q | M)
    static func hash(_ q: Data, message: Message, publicKey: PublicKey<Curve>) -> Data {
        let compressPubKey = publicKey.data.compressed
        let msgData = message.asData()
        // Public key is a point (x, y) on the curve.
        // Each coordinate requires 32 bytes.
        // In its compressed form it suffices to store the x co-ordinate
        // and the sign for y.
        // Hence a total of 33 bytes.
        let PUBKEY_COMPRESSED_SIZE_BYTES: Int = 33
        precondition(compressPubKey.bytes.count == PUBKEY_COMPRESSED_SIZE_BYTES)

        // TODO ensure BIG ENDIAN
        precondition(q.bytes.count >= PUBKEY_COMPRESSED_SIZE_BYTES)
        let Q = Data(q.bytes.prefix(PUBKEY_COMPRESSED_SIZE_BYTES))

        return Crypto.sha2Sha256(Q + compressPubKey + msgData)
    }

    static func trySign(_ message: Message, privateKey: PrivateKey<Curve>, k: Number, publicKey: PublicKey<Curve>) -> Signature<Curve> {

        guard privateKey.number > 0 else { fatalError("bad private key") }
        guard privateKey.number < Curve.order else { fatalError("bad private key") }

        // 1a. check that k is not 0
        guard k > 0 else { fatalError("bad k") }
        // 1b. check that k is < the order of the group
        guard k < Curve.order else { fatalError("bad k") }

        // 2. Compute commitment Q = kG, where g is the base point
        let Q = Curve.G * k
        // convert the commitment to octets first
        let compressedQ = PublicKey(point: Q).data.compressed

        // 3. Compute the challenge r = H(Q || pubKey || msg)
        let r = Number(data: hash(compressedQ, message: message, publicKey: publicKey))

        guard r > 0 else { fatalError("bad r") }
        guard r <= Curve.order else { fatalError("bad r") }

        // 4. Compute s = k - r * prv
        let s = Curve.modN { k - (r * privateKey.number) }

        guard s > 0 else { fatalError("bad S") }

        return Signature<Curve>(r: r, s: s)!
    }

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

