//
//  Prime.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Prime {
    public let number: Number
    public init?(_ number: Number) {
        guard number.isPrime() else { return nil }
        self.number = number
    }
}
