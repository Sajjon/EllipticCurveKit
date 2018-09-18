//
//  ECDSA.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-19.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public struct ECDSA<CurveType: EllipticCurve>: Signing {
    public typealias Curve = CurveType
}
public extension ECDSA {

    static func sign(_ message: Message, using keyPair: KeyPair<Curve>) -> Signature<Curve> {
        return sign(message, privateKey: keyPair.privateKey, publicKey: keyPair.publicKey)
    }

    static func sign(_ message: Message, privateKey: PrivateKey<Curve>, publicKey: PublicKey<Curve>) -> Signature<Curve> {
        return ECDSA._sign(message, privateKey: privateKey, publicKey: publicKey)
    }

    // ECDSA signature is a pair of numbers: (Kx, s)
    // Where Kx = x coordinate of k*G mod n (n is the order of secp256k1).
    // And s = (k^-1)*(h + Kx*privkey).
    // By default, k is chosen randomly on interval [0, n - 1].
    // But this makes signatures harder to test and allows faulty or backdoored RNGs to leak private keys from ECDSA signatures.
    // To avoid these issues, we'll generate k = Hash256(hash || privatekey) and make all computations by hand.
    //
    // Note: if one day you think it's a good idea to mix in some extra entropy as an option,
    //       ask yourself why Hash(message || privkey) is not unpredictable enough.
    //       IMHO, it is as predictable as privkey and making it any stronger has no point since
    //       guessing the privkey allows anyone to do the same as guessing the k: sign any
    //       other transaction with that key. Also, the same hash function is used for computing
    //       the message hash and needs to be preimage resistant. If it's weak, anyone can recover the
    //       private key from a few observed signatures. Using the same function to derive k therefore
    //       does not make the signature any less secure.
    static func _sign(_ message: Message, privateKey: PrivateKey<Curve>, publicKey: PublicKey<Curve>, hasher: UpdatableHasher = UpdatableHashProvider.hasher(variant: .sha2sha256)) -> Signature<Curve> {

        /*
         For Alice to sign a message {\displaystyle m} m, she follows these steps:

         1. Calculate `e = HASH(m)`, where `HASH` is a cryptographic hash function, such as `SHA-2`.
         2. Let `z` be the `L` leftmost bits of `e`, where `L` is the bit length of the group order `n`.
         3. Select a cryptographically secure random integer `k` from `[1, n-1]`
         4. Calculate the curve point (x1, y1) = k * G
         5. Calculate `r = x1 mod n`. If `r == 0`, go back to step 3.
         6. Calculate `s = k^(-1) * (z + r * seckey) mod n`. If `s == 0`, go back to step 3.
         7. The signature is the pair `(r, s)`
         */
        let z = message.asData().toNumber()

        var r: Number = 0
        var s: Number = 0
        let d = privateKey.number

        repeat {
            var k = privateKey.signatureNonceK(forHashedData: z.as256bitLongData(), digestLength: hasher.digestLength)
            k = Curve.modN { k } // make sure k belongs to [0, n - 1]

            let point: Curve.Point = Curve.G * k
            r = Curve.modN { point.x }
            guard !r.isZero else { continue }
            let kInverse = Curve.modInverseN(1, k)
            s = Curve.modN { kInverse * (z + r * d) }
        } while s.isZero
        return Signature(r: r, s: s, ensureLowSAccordingToBIP62: Curve.name == .secp256k1)!
    }

    /// TODO implement Greg Maxwells trick for verify: https://github.com/indutny/elliptic/commit/b950448bc9c7af9ffd077b32919fe6e7b72b2eba
    /// Assumes that signature.r and signature.s ~= 1...Curve.N
    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {
        guard publicKey.point.isOnCurve() else { return false }
        let z = message.asData().toNumber()
        let r = signature.r
        let s = signature.s
        let H = publicKey.point

        let sInverse = Curve.modInverseN(Number(1), s)

        let u1 = Curve.modN { sInverse * z }
        let u2 = Curve.modN { sInverse * r }

        guard
            let R = Curve.addition(Curve.G * u1, H * u2),
            case let verification = Curve.modN({ R.x }),
            verification == r
            else { return false }

        return true
    }
}
