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
            signature = try! trySign(message, privateKey: privateKey, k: K, publicKey: publicKey)
        }

        return signature!
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {

        guard signature.s < Curve.N else { print("incorrect S value in signature"); return false }
        guard signature.r < Curve.N else { print("incorrect R value in signature"); return false }

        let l = publicKey.point * signature.r
        let r = Curve.G * signature.s

        let Q = Curve.addition(l, r)!
        let compressedQ = PublicKey<Curve>(point: Q).data.compressed

        let r1 = hash(compressedQ, publicKey: publicKey, message: message, hasher: message.hashedBy).asNumber

        guard r1 < Curve.N, r1 > 0 else { print("invalid hash"); return false }

        let signatureDidSignMessageUsingPublicKey = r1 == signature.r

        return signatureDidSignMessageUsingPublicKey
    }
}

// MARK: - Internal Methods
extension Schnorr {

    public enum Error: Swift.Error {
        case privateKeyNegative
        case privateKeyEqualToOrGreaterThanCurveOrder
        case deterministicRandomNonceNegative
        case deterministicRandomNonceEqualToOrGreaterThanCurveOrder
        case challengeFromHashNegative
        case challengeFromHashEqualToOrGreaterThanCurveOrder
        case signaturePart_S_Negative
    }

    static func trySign(_ message: Message, privateKey: PrivateKey<Curve>, k: Number, publicKey: PublicKey<Curve>) throws -> Signature<Curve> {

        guard privateKey.number > 0 else { throw Error.privateKeyNegative }
        guard privateKey.number < Curve.order else { throw Error.privateKeyEqualToOrGreaterThanCurveOrder }

        // 1a. check that k is not 0
        guard k > 0 else { throw Error.deterministicRandomNonceNegative }
        // 1b. check that k is < the order of the group
        guard k < Curve.order else { throw Error.deterministicRandomNonceEqualToOrGreaterThanCurveOrder }

        // 2. Compute commitment Q = kG, where g is the base point
        let Q = Curve.G * k
        // convert the commitment to octets first
        let compressedQ = PublicKey(point: Q).data.compressed

        // 3. Compute the challenge r = H(Q || pubKey || msg)
        let r = hash(compressedQ, publicKey: publicKey, message: message, hasher: message.hashedBy).asNumber

        guard r > 0 else { throw Error.challengeFromHashNegative }
        guard r < Curve.order else { throw Error.challengeFromHashEqualToOrGreaterThanCurveOrder }

        // 4. Compute s = k - r * prv
        let s = Curve.modN { k - (r * privateKey.number) }

        guard s > 0 else { throw Error.signaturePart_S_Negative }

        return Signature<Curve>(r: r, s: s)!
    }
}

// MARK: - Private
private extension Schnorr {
    /// Hash (q | M)
    static func hash(_ q: Data, publicKey: PublicKey<Curve>, message: Message, hasher: Hasher) -> Data {
        let compressedPubKey = publicKey.data.compressed
        return hasher.hash(q.prefix(compressedPubKey.byteCount) + compressedPubKey + message)
    }
}
