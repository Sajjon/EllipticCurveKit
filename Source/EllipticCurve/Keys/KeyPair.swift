//
//  KeyPair.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-12.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyPair {
    let privateKey: PrivateKey
    let publicKey: PublicKey

    public init(`private`: PrivateKey, `public`: PublicKey) {
        self.privateKey = `private`
        self.publicKey = `public`
    }
}

