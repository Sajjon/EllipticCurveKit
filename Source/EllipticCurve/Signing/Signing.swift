//
//  Signing.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Signing {
    /// Elliptic Curve used, e.g. `secp256k1`
    associatedtype Curve: EllipticCurve

    /// `personalizationStringDRBG` refers to the HMAC_DRBG personalization string ("pers").
    static func sign(_ message: Message, using keyPair: KeyPair<Curve>, personalizationDRBG: Data?) -> Signature<Curve>

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool
}

public extension Signing {
    static func sign(_ message: Message, using keyPair: KeyPair<Curve>) -> Signature<Curve> {
        return sign(message, using: keyPair, personalizationDRBG: nil)
    }
}
