//
//  Field.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Field {
    let prime: Prime
    let a: Number
    let b: Number
    public init(prime: Prime, a: Number, b: Number) {
        self.prime = prime
        self.a = a
        self.b = b
    }
}

