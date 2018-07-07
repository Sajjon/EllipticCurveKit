//
//  KeyCreator.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyGenerator {
    func generateKeyPair() -> KeyPair
}

public class DefaultKeyGenerator {
    let curve: EllipticCurve
    init(curve: EllipticCurve) {
        self.curve = curve
    }
}

extension DefaultKeyGenerator: KeyGenerator {}
public extension DefaultKeyGenerator {
    func generateKeyPair() -> KeyPair {
        fatalError()
    }
}
