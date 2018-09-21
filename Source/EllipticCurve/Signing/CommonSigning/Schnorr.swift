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

    static func sign(_ message: Message, using keyPair: KeyPair<CurveType>, personalizationDRBG: Data?) -> Signature<CurveType> {

        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey

        let drbg = HMAC_DRBG(message: message, privateKey: privateKey, personalization: personalizationDRBG)

        var signature: Signature<Curve>?
        var K: Number!
        while signature == nil {
            let k = try! drbg.generateNumberOfLength(byteCount: Curve.N.byteCount)
            K = Number(data: k)
            signature = trySign(message, privateKey: privateKey, k: K, publicKey: publicKey)
        }

        return signature!
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {

        guard signature.s < Curve.N else { fatalError("incorrect S value in signature") }
        guard signature.r < Curve.N else { fatalError("incorrect R value in signature") }

        let l = publicKey.point * signature.r
        let r = Curve.G * signature.s

        let Q = Curve.addition(l, r)!
        let compressedQ = PublicKey<Curve>(point: Q).data.compressed

        let r1 = hash(compressedQ, publicKey: publicKey, message: message, hasher: message.hashedBy).asNumber

        guard r1 < Curve.N, r1 > 0 else { fatalError("invalid hash") }

        let signatureDidSignMessageUsingPublicKey = r1 == signature.r

        assert(signatureDidSignMessageUsingPublicKey, "r1: `\(r1)`, sig.r: `\(signature.r)`")

        return signatureDidSignMessageUsingPublicKey
    }
}

// MARK: - Internal Methods
extension Schnorr {

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
        let r = hash(compressedQ, publicKey: publicKey, message: message, hasher: message.hashedBy).asNumber

        guard r > 0 else { fatalError("bad r") }
        guard r <= Curve.order else { fatalError("bad r") }

        // 4. Compute s = k - r * prv
        let s = Curve.modN { k - (r * privateKey.number) }

        guard s > 0 else { fatalError("bad S") }

        return Signature<Curve>(r: r, s: s)!
    }
}

// MARK: - Private
private extension Schnorr {
    /// Hash (q | M)
    static func hash(_ q: Data, publicKey: PublicKey<Curve>, message: Message, hasher: Hasher) -> Data {
        let compressPubKey = publicKey.data.compressed
        let msgData: DataConvertible = message
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

        let dataToHash = Q + compressPubKey + msgData
        let hashedData = hasher.hash(dataToHash)
        return hashedData
    }
}
