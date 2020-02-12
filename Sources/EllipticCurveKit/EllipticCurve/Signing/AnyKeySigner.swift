//
//  AnyKeySigner.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-16.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct AnyKeySigner<SigningMethod: Signing>: Signing {
    public typealias Curve = SigningMethod.Curve
}

public extension AnyKeySigner {

    static func sign(_ message: Message, using keyPair: KeyPairType, personalizationDRBG: Data?) -> SignatureType {
        return SigningMethod.sign(message, using: keyPair, personalizationDRBG: personalizationDRBG)
    }

    static func verify(_ message: Message, wasSignedBy signature: SignatureType, publicKey: PublicKeyType) -> Bool {
        return SigningMethod.verify(message, wasSignedBy: signature, publicKey: publicKey)
    }
}

public extension AnyKeySigner {
    typealias KeyPairType = KeyPair<Curve>
    typealias PublicKeyType = PublicKey<Curve>
    typealias SignatureType = Signature<Curve>
}
